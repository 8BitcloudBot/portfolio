---
title: "RAG 面试速查：索引优化深度解析（句子窗口检索 + 结构化递归检索）"
description: "覆盖句子窗口检索、结构化递归检索、元数据、索引构建本质、子查询引擎、LLM 介入时机等面试高频问题，附完整 RAG 知识地图"
pubDate: 2025-09-06
tags: ["RAG", "索引优化", "LlamaIndex", "句子窗口检索", "结构化索引", "递归检索", "面试"]
lang: "zh"
---

# RAG 面试速查：索引优化深度解析

本文基于 Datawhale 的 all-in-rag 教程第三章第五节「索引优化」，结合 LlamaIndex 源码与实践代码，系统梳理面试高频考点。

---

## 一、检索方法的分类体系

在讨论具体技术之前，先建立全局分类视角。RAG 的所有优化方法可以分为三个层面：

```
RAG 优化方法
├── ① 索引优化（Index Optimization）—— "怎么存"
│   ├── 分块策略优化：固定 / 递归 / 语义分块
│   ├── 上下文扩展（Context Enrichment）
│   │   ├── 句子窗口检索（Sentence Window Retrieval）
│   │   └── 父子块检索（Parent-Child Chunking）
│   └── 结构化索引（Structured Index）
│       ├── 元数据索引（Metadata Indexing）
│       └── 递归检索（Recursive Retrieval）
│
├── ② 检索优化（Retrieval Optimization）—— "怎么搜"
│   ├── 混合检索（Hybrid Search）：向量 + 关键词 BM25
│   ├── 查询构建（Query Construction）：Text-to-DSL / SQL
│   ├── 查询重写（Query Rewriting）：扩展 / 分解 / 改述查询
│   └── 高级检索技术：多跳、自纠错、CRAG
│
└── ③ 生成优化（Generation Optimization）—— "怎么答"
    ├── 格式化生成、Prompt 工程
    └── 引用溯源
```

**关键区分**：

| 维度 | 索引优化 | 检索优化 |
|------|---------|---------|
| 优化对象 | 存储方式：文档怎么切、怎么存、怎么组织 | 搜索方式：查询怎么处理、怎么找、怎么排序 |
| 发生时机 | 索引构建阶段（一次性完成） | 查询阶段（每次查询都执行） |
| 口诀 | "怎么存" | "怎么搜" |

> **面试话术**：句子窗口检索和结构化递归检索都属于"索引优化"层面，核心动作发生在索引构建阶段，而不是检索阶段。

---

## 二、句子窗口检索（Sentence Window Retrieval）

### 2.1 一句话定义

> 索引时用单句保证检索精度，生成前用上下文窗口保证回答质量。

### 2.2 解决了什么问题？

传统 RAG 面临的两难：

| 分块策略 | 检索精度 | 生成质量 | 问题 |
|---------|---------|---------|------|
| 小块（单句） | 高 | 差 | 缺乏上下文，LLM 无法连贯作答 |
| 大块（段落） | 低 | 好 | 引入噪音，检索不精准 |
| **句子窗口** | 高 | 好 | 两者兼顾 |

### 2.3 核心流程

```
索引阶段 ──→ 检索阶段 ──→ 后处理阶段 ──→ 生成阶段
```

| 阶段 | 做什么 | 关键点 |
|------|--------|--------|
| 索引 | 文档切分为单句，每个句子存为一个 Node；同时把前后各 N 句作为"窗口"存入 metadata | 窗口文本不参与向量化，只存 metadata |
| 检索 | 用户问题向量化，在单句索引上做相似度搜索 | 精准定位核心句子 |
| 后处理 | `MetadataReplacementPostProcessor` 用 metadata 中的窗口文本替换原来的单句 | 送入 LLM 前"膨胀"上下文 |
| 生成 | 包含丰富上下文的节点送入 LLM 生成回答 | 质量大幅提升 |

### 2.4 代码实现

```python
from llama_index.core import SimpleDirectoryReader, VectorStoreIndex
from llama_index.core.node_parser import SentenceWindowNodeParser, SentenceSplitter
from llama_index.core.postprocessor import MetadataReplacementPostProcessor

# 1. 加载文档
documents = SimpleDirectoryReader(
    input_files=["../../data/C3/pdf/IPCC_AR6_WGII_Chapter03.pdf"]
).load_data()

# 2. 创建句子窗口索引
node_parser = SentenceWindowNodeParser.from_defaults(
    window_size=3,                      # 前后各 3 个句子
    window_metadata_key="window",       # 窗口文本存入 metadata 的 key
    original_text_metadata_key="original_text",
)
sentence_nodes = node_parser.get_nodes_from_documents(documents)
sentence_index = VectorStoreIndex(sentence_nodes)

# 3. 创建常规索引（基准对比）
base_parser = SentenceSplitter(chunk_size=512)
base_nodes = base_parser.get_nodes_from_documents(documents)
base_index = VectorStoreIndex(base_nodes)

# 4. 构建查询引擎（关键：后处理器）
sentence_query_engine = sentence_index.as_query_engine(
    similarity_top_k=2,
    node_postprocessors=[
        MetadataReplacementPostProcessor(target_metadata_key="window")
    ],
)
base_query_engine = base_index.as_query_engine(similarity_top_k=2)

# 5. 执行查询并对比
query = "What are the concerns surrounding the AMOC?"
window_response = sentence_query_engine.query(query)
base_response = base_query_engine.query(query)
```

### 2.5 SentenceWindowNodeParser 底层逻辑

| 步骤 | 方法 | 功能 |
|------|------|------|
| 句子切分 | `split_by_sentence_tokenizer` | 将文档切分成句子列表 |
| 创建节点 | `build_nodes_from_splits` | 为每个句子创建独立的 TextNode |
| 构建窗口 | 主循环 + 切片 | `nodes[max(0, i-window_size) : min(i+window_size+1, len(nodes))]` |
| 填充元数据 | 元数据操作 | 存储 "window" 和 "original_text" |
| 设置排除项 | `excluded_embed_metadata_keys` | 确保只有单句用于向量化，窗口文本不污染嵌入 |

> **细节加分**：`excluded_embed_metadata_keys` 确保只有单句文本被向量化，窗口文本仅供 `MetadataReplacementPostProcessor` 使用。

### 2.6 面试常见问答

**Q1：window_size 设多大合适？**

默认 3（前后各 3 句，共 7 句）。太大 → 噪音增加，检索精度下降；太小 → 上下文不足。需要根据文档类型实验调优。

**Q2：句子窗口检索和 Parent-Child Chunking 有什么区别？**

思路相似（小块检索 + 大块送入 LLM），但实现不同：句子窗口用 metadata 存储窗口文本，Parent-Child 用父子关系链接小块和大块。

**Q3：MetadataReplacementPostProcessor 是在检索前还是检索后？**

检索后，是一个后处理器（postprocessor）。它在检索到节点之后、送入 LLM 之前介入。

---

## 三、结构化索引与递归检索（Recursive Retrieval）

### 3.1 一句话定义

> 结构化索引 = 给文档附加元数据标签，检索时先过滤再搜索；递归检索 = 先路由到正确的数据源，再在该源内部精确查询。

### 3.2 解决了什么问题？

传统 RAG 在大规模知识库中的瓶颈：

```
知识库 1000 个文档
→ 用户问 "2023年Q2财报中AI相关内容"
→ 全量向量搜索 → 998 个无关文档的噪音污染
→ 效率低 + 精度差
```

结构化索引的解法：

```
先用元数据过滤 → 只保留 Q2 财报相关文档
→ 在小范围内向量搜索
→ 效率高 + 精度高
```

### 3.3 元数据（Metadata）详解

**元数据是什么？**

元数据是附着在每个 Document/Node 上的键值对字典，不是文档正文本身，而是"关于这份文档的描述信息"。

**元数据怎么来？**

| 获取方式 | 说明 | 示例 |
|---------|------|------|
| 手动指定 | 你自己决定要标记什么 | `metadata={"sheet_name": "年份_1994"}` |
| 框架自动提取 | MarkdownHeaderTextSplitter 等自动提取标题层级 | `{"Header 1": "第三章", "Header 2": "第五节"}` |
| LLM 提取 | 用 LLM 从非结构化文本中抽取 | 时间、作者、分类标签等 |

在我们的实践中，"年份"信息不是从文档内容里提取的，而是从 Excel 的工作表名里直接拿的：

```python
sheet_name = "年份_1994"
year = sheet_name.replace('年份_', '')  # → "1994"
metadata = {"sheet_name": sheet_name}   # 直接附加
```

> **面试关键点**：元数据没有固定格式，你想标记什么就标记什么，关键是后续检索时要用得上。

### 3.4 索引构建的本质

`VectorStoreIndex(all_docs)` 做了以下事情：

```
文档列表
→ 嵌入模型逐个将 text 字段转为向量
→ 向量存入内存向量库（SimpleVectorStore）
```

具体来说：

1. 取每个 Document 的 `text` 字段
2. 调用 `Settings.embed_model`（如 bge-small-zh-v1.5）把文本转为 512 维向量
3. 向量存入 SimpleVectorStore
4. **元数据不参与向量化**，但会随向量一起存储，供后续过滤使用

> **面试关键点**：索引的核心是把文本变成数学向量，相似语义的文本在向量空间中距离近。元数据只做过滤，不做向量化。

### 3.5 两种实现方式对比

| 方式 | 核心组件 | 实现思路 |
|------|---------|---------|
| 手动两步式 | `VectorIndexRetriever` + `MetadataFilters` | 自己写路由逻辑，手动过滤 metadata |
| `RecursiveRetriever` | `RecursiveRetriever` + `IndexNode` + `PandasQueryEngine` | LlamaIndex 内置，自动"摘要路由 → 数据源查询" |

#### 方式一：手动两步式

```python
# 第 1 步：在摘要索引中路由
summary_retriever = VectorIndexRetriever(index=summary_index, similarity_top_k=1)
retrieved_nodes = summary_retriever.retrieve(query_str)
matched_sheet_name = retrieved_nodes[0].node.metadata['sheet_name']

# 第 2 步：在内容索引中过滤 + 检索
content_retriever = VectorIndexRetriever(
    index=content_index,
    similarity_top_k=1,
    filters=MetadataFilters(
        filters=[ExactMatchFilter(key="sheet_name", value=matched_sheet_name)]
    )
)
query_engine = RetrieverQueryEngine.from_args(content_retriever)
response = query_engine.query(query_str)
```

> `ExactMatchFilter` 就是 SQL 里的 `WHERE sheet_name = '年份_1994'`，先缩小范围再做向量搜索。

#### 方式二：RecursiveRetriever

```python
# 为每个工作表创建 PandasQueryEngine + IndexNode
for sheet_name in xls.sheet_names:
    df = pd.read_excel(xls, sheet_name=sheet_name)
    query_engine = PandasQueryEngine(df=df, llm=Settings.llm)
    node = IndexNode(text=summary, index_id=sheet_name)
    df_query_engines[sheet_name] = query_engine

# 创建递归检索器
vector_retriever = vector_index.as_retriever(similarity_top_k=1)
recursive_retriever = RecursiveRetriever(
    "vector",
    retriever_dict={"vector": vector_retriever},
    query_engine_dict=df_query_engines,
)
```

### 3.6 子查询引擎的实质

在递归检索中，子查询引擎是 `PandasQueryEngine`，它的实质是一个**"代码生成 + 执行"管道**，不是向量搜索：

```
用户问题 "1994年评分人数最少的电影？"
    ↓
PandasQueryEngine 把问题 + DataFrame 的 schema（列名、数据类型）发给 LLM
    ↓
LLM 生成 pandas 代码：df.loc[df['评分人数'].idxmin(), '电影名称']
    ↓
PandasQueryEngine 执行这段代码（内部使用 eval()）
    ↓
返回执行结果："《燃情岁月》"
```

> **面试关键点**：子查询引擎不是向量检索，是 Text-to-Code（文本转代码）。LLM 写代码，框架执行代码。这也意味着 PandasQueryEngine 存在安全隐患（eval 执行任意代码），生产环境慎用。

### 3.7 DataFrame 从哪来？

在实践中，就是直接从 Excel 读出来的：

```python
excel_file = '../../data/C3/excel/movie.xlsx'
xls = pd.ExcelFile(excel_file)
df = pd.read_excel(xls, sheet_name=sheet_name)  # ← 就是这个 df
query_engine = PandasQueryEngine(df=df, llm=Settings.llm)
```

完整链路：

```
Excel 文件 → pd.read_excel() 读为 DataFrame
→ DataFrame 传给 PandasQueryEngine
→ 内部把 DataFrame 的 schema（列名、类型、前几行样例）发给 LLM
→ LLM 根据 schema + 用户问题生成 pandas 代码
```

### 3.8 索引中的"时间点、类别"等数据怎么提取？

| 数据类型 | 提取方式 | 示例 |
|---------|---------|------|
| 文件名/工作表名 | 从数据源结构中直接获取 | `sheet_name = "年份_1994"` |
| 标题层级 | 框架自动提取（MarkdownHeaderTextSplitter） | `"Header 1": "第三章"` |
| 时间/日期 | 代码解析或 LLM 提取 | 正则匹配、从文件名提取 |
| 自定义分类 | 手动附加或 LLM 标注 | `metadata={"category": "电影"}` |

---

## 四、LLM 在哪些环节介入？

这是面试中区分"理解深度"的关键问题。

### 4.1 纯向量检索方案（手动两步式）

```
┌─────────────────── 索引阶段 ───────────────────┐
│  Document → 嵌入模型 → 向量 → 存入向量库          │
│  LLM 不介入，只有嵌入模型工作                      │
└──────────────────────────────────────────────────┘

┌─────────────────── 检索阶段 ───────────────────┐
│  用户问题 → 嵌入模型 → 查询向量                   │
│  → 向量相似度搜索 → 返回最相关节点                 │
│  LLM 不介入，纯向量数学运算                        │
└──────────────────────────────────────────────────┘

┌─────────────────── 生成阶段 ───────────────────┐
│  检索到的文档内容 + 用户问题 → 拼接成 Prompt       │
│  → 发送给 LLM  ← LLM 第 1 次介入（也是唯一一次）  │
│  → LLM 生成最终回答                               │
└──────────────────────────────────────────────────┘
```

**总计：LLM 只介入 1 次（最终生成回答时）。**

### 4.2 RecursiveRetriever + PandasQueryEngine 方案

```
┌─── 第 1 次 LLM 介入（子查询引擎内部）─────────────┐
│  "1994年评分人数最少的电影？" + DataFrame schema    │
│  → 发送给 LLM → LLM 生成 pandas 代码              │
│  → 框架执行代码，得到结果                           │
└───────────────────────────────────────────────────┘

┌─── 第 2 次 LLM 介入（最终生成）──────────────────┐
│  第 1 次的结果 + 用户原始问题                       │
│  → 发送给 LLM → LLM 生成自然语言回答               │
└───────────────────────────────────────────────────┘
```

**总计：LLM 介入 2 次。PandasQueryEngine 内部会先调用一次 LLM 生成代码。**

### 4.3 两次 LLM 可以不一致吗？

**可以不一致！** LlamaIndex 的架构允许每个组件独立配置 LLM：

```python
# PandasQueryEngine 可以单独指定 LLM
query_engine = PandasQueryEngine(
    df=df,
    llm=some_fast_model,      # 第 1 次用便宜快速的模型（写代码不需要太强）
)
# 最终的 RetrieverQueryEngine 用全局 Settings.llm（DeepSeek）
# 第 2 次用更强的模型（生成回答需要更好的语言能力）
```

| 环节 | 对 LLM 的要求 | 推荐策略 |
|------|--------------|---------|
| 生成 pandas 代码 | 理解 DataFrame schema + 代码能力 | 可以用小/快模型（如 deepseek-coder） |
| 最终生成回答 | 语言表达能力、综合理解能力 | 用强模型（如 deepseek-chat） |

> **面试加分回答**：可以不一致。LlamaIndex 的架构允许每个组件独立配置 LLM。子查询引擎负责代码生成，对模型要求是代码能力；最终回答负责语言生成，对模型要求是语言表达能力。两者可以分别选择最适合的模型。

---

## 五、句子窗口检索 vs 结构化递归检索 对比

| 维度 | 句子窗口检索 | 结构化递归检索 |
|------|------------|--------------|
| **解决的问题** | 小块检索精准但上下文不足 | 大规模知识库检索范围过大 |
| **优化层面** | 检索后的上下文补全 | 检索前的范围缩小 |
| **核心机制** | metadata 存窗口 + 后处理替换 | 元数据过滤 + 路由到子索引 |
| **适用场景** | 单文档深度问答 | 多文档/多表格跨源查询 |
| **关键组件** | `SentenceWindowNodeParser` + `MetadataReplacementPostProcessor` | `IndexNode` + `RecursiveRetriever` + `PandasQueryEngine` |
| **LLM 介入次数** | 1 次（最终生成） | 2 次（子查询引擎 + 最终生成） |
| **在知识地图中的位置** | 索引优化 → 上下文扩展 | 索引优化 → 结构化索引 |

### 速记口诀

| 技术 | 口诀 |
|------|------|
| 句子窗口检索 | 索引小块保精度，后处理窗口补上下文 |
| 结构化索引 | 元数据标签做路由，先过滤再搜索 |
| 递归检索 | 摘要定位数据源，子引擎内部精确查 |

---

## 六、完整 RAG 知识地图

```
RAG 四步流水线
│
├── 第一章 解锁 RAG（入门）
│   └── 整体概念：数据准备 → 索引构建 → 检索 → 生成
│
├── 第二章 数据准备（Data Preparation）
│   ├── 数据加载：PDF / Markdown / Excel 怎么读
│   └── 文本分块：固定 / 递归 / 语义分块
│
├── 第三章 索引构建（Index Construction）⭐ 本节所在
│   ├── 向量嵌入：文本→向量（bge, OpenAI embedding）
│   ├── 多模态嵌入：图片→向量（CLIP, visual bge）
│   ├── 向量数据库：向量存哪里（Milvus, FAISS, ChromaDB）
│   └── 索引优化：
│       ├── 上下文扩展 → 句子窗口检索 ← 解决"切小了上下文不够"
│       └── 结构化索引 → 结构化递归检索 ← 解决"数据源太多搜不准"
│
├── 第四章 检索优化（Retrieval Optimization）
│   ├── 混合检索：向量 + BM25 关键词
│   ├── 查询构建：自然语言→结构化查询（Text2SQL）
│   ├── 查询重写：改述 / 分解 / 扩展用户问题
│   └── 高级检索：多跳、自纠错、CRAG
│
├── 第五章 生成集成（Generation）
│   └── Prompt 工程、格式化输出、引用溯源
│
├── 第六章 评估（Evaluation）
│   └── Recall, Faithfulness, Answer Relevance
│
└── 第七章 高级架构（Advanced）
    └── 知识图谱 RAG（Graph RAG）
```

---

## 七、面试高频问答汇总

### 基础概念

**Q：什么是元数据？怎么来的？**

元数据是附着在 Document 上的键值对字典，不参与向量化，用于过滤和标记。获取方式有三种：手动指定（如 `metadata={"sheet_name": "年份_1994"}`）、框架自动提取（如 MarkdownHeaderTextSplitter 提取标题层级）、LLM 提取（从非结构化文本中抽取时间/作者/分类等）。

**Q：索引构建的本质是什么？**

索引构建的本质是把文本变成数学向量：Document 的 text 字段 → 嵌入模型转为高维向量 → 向量存入向量库。元数据不参与向量化，但随向量一起存储供后续过滤使用。

### 技术原理

**Q：句子窗口检索解决了什么问题？**

解决了"小块检索精准但上下文不足"和"大块上下文丰富但检索不准"之间的矛盾。索引时按单句切分保证精度，检索后用 MetadataReplacementPostProcessor 扩展上下文窗口保证生成质量。

**Q：RecursiveRetriever 的工作原理？**

在摘要索引中向量检索找到对应的 IndexNode → 根据 index_id 路由到子查询引擎 → 子查询引擎（如 PandasQueryEngine）内部执行查询 → 返回结果。

**Q：PandasQueryEngine 的实质是什么？**

是 Text-to-Code 管道。LLM 根据用户问题 + DataFrame schema 自动生成 pandas 代码，框架执行代码返回结果。不是向量搜索，是代码生成 + 执行。

### LLM 介入

**Q：LLM 在哪些环节介入？**

纯向量检索方案（手动两步式）：LLM 只在最终生成回答时介入 1 次。RecursiveRetriever + PandasQueryEngine 方案：LLM 介入 2 次（子查询引擎内部生成 pandas 代码 + 最终生成自然语言回答）。

**Q：两次 LLM 可以不一致吗？**

可以。LlamaIndex 的架构允许每个组件独立配置 LLM。子查询引擎可以用小/快模型（代码生成），最终回答用强模型（语言表达）。

### 分类与定位

**Q：句子窗口检索和结构化递归检索分别属于什么类别？**

都属于"索引优化"层面。句子窗口检索属于"上下文扩展"（优化单文档内部的存储粒度），结构化递归检索属于"结构化索引"（优化多文档/数据源之间的组织方式）。两者和"检索优化"（混合检索、查询重写等）是不同层面的技术。
