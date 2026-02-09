---
date: '2026-02-09T20:00:00+02:00'
title: 'Database Theory: How Databases Work Under the Hood'
description: "Comprehensive notes on database theory: conceptual, logical, and physical design, relational algebra, SQL (MySQL), storage organization (hashing, B-trees, indexes), transactions, ACID properties, serializability, and locking protocols."
tags: ["databases", "sql", "relational-algebra", "transactions", "b-tree", "hashing", "indexes", "acid", "notes"]
categories: ["Engineering"]
searchable: true
math: true
---

## Introduction

Databases are at the heart of virtually every software system — from web applications to financial platforms to machine learning pipelines. But how do they actually work? What happens when you run a `SELECT` query? How are rows stored on disk? How do multiple transactions run concurrently without corrupting data?

This post is a comprehensive guide to **database theory**, covering the full lifecycle of database design and operation: from conceptual modeling to physical storage, from SQL queries to concurrency control. Whether you are studying for an exam, preparing for a systems design interview, or simply curious about what happens beneath the ORM layer, this guide has you covered.

We will walk through five major topics:

1. **Database Design** — conceptual, logical, and physical modeling
2. **Relational Algebra** — the mathematical foundation of queries
3. **SQL (MySQL)** — practical query language
4. **Storage Organization** — how data lives on disk (hashing, trees, indexes)
5. **Transactions** — ACID properties, serializability, and locking

---

## 1. Database Design

Designing a database is a structured process that moves through three phases: **conceptual**, **logical**, and **physical** design. Each phase takes the output of the previous one and refines it further.

### 1.1 Conceptual Design

Conceptual design takes **functional requirements** from the user and produces an **Entity-Relationship (E/R) schema** — a diagram that represents entities and the relationships between them.

#### Entity

An **entity** represents a self-standing concept (like *Student*, *Course*, or *Employee*). Every entity must have at least one **key**. You can think of an entity as the concept of a mathematical *set*.

```
┌────────────────┐
│    Student     │
├────────────────┤
│ StudentID (PK) │
│ Name           │
│ Age            │
└────────────────┘
```

#### Relationship

A **relationship** between two or more entities represents the mathematical concept of a relation between two or more sets. A relationship between two sets is defined by the **Cartesian product** — the set of all possible pairs $(e_1, e_2)$ such that $e_1$ belongs to the first set and $e_2$ belongs to the second.

```
┌──────────┐         ┌──────────────┐         ┌──────────┐
│ Employee │────────▶│  WorksOn     │◀────────│ Project  │
└──────────┘         └──────────────┘         └──────────┘
```

#### Attributes

Attributes represent the **characteristics** of an entity or a relationship. They cannot be used to represent concepts like lists.

#### Cardinality

Cardinality is a concept associated with relationships. It represents the **number of entity occurrences** that can participate in a relationship. It must always be defined on both sides of every relationship.

For example: an employee can participate in **only one** project, while a project can have **1 to N** employees.

```
┌──────────┐  1    N  ┌──────────┐
│ Employee │──────────│ Project  │
└──────────┘          └──────────┘
```

Common cardinality types:

| Cardinality | Meaning |
|-------------|---------|
| **1:1** | Each entity on both sides participates in at most one relationship |
| **1:N** | One side has at most one, the other can have many |
| **N:M** | Both sides can have many |

#### Key

The concept of a **key** is one of the most fundamental in the E/R model. A key can be an attribute, a concept, a set of attributes, a set of concepts, or a combination of both.

> **Definition:** A key is a set of concepts (attributes or entities) that **uniquely identifies an entity** and is **minimal** with respect to the property of being a key.

**Minimal** means that no proper subset of the key is also a key.

In the case of a **mixed or external key**, the cardinality on the key side must be **1:1**.

There are three types of keys:

| Key Type | Description |
|----------|-------------|
| **Internal Key** | The entity is identified by one or more attributes internal to the entity |
| **External Key** | The entity is identified by a second entity with which it is in a relationship |
| **Mixed Key** | The entity is identified by a combination of internal attributes and an external relationship |

#### Generalization

A **generalization** is a link between two entities — a **parent** and a **child**. Everything belonging to the parent is inherited by the child. Additionally, every occurrence of the child is also an occurrence of the parent.

Generalizations have two key properties:

| Property | Options | Description |
|----------|---------|-------------|
| **Coverage** | **Total** | Every occurrence of the parent *must* be an occurrence of one of the children |
| | **Partial** | A parent occurrence does *not* have to be an occurrence of any child |
| **Exclusiveness** | **Exclusive** | Every occurrence of the parent can be an occurrence of *only one* child |
| | **Inclusive** | Every occurrence of the parent can be an occurrence of *multiple* children simultaneously |

**Example:** Consider a generalization where *Person* is the parent, and *Student* and *Worker* are children.

- **Total + Exclusive:** Every person must be either a student or a worker, but not both.
- **Partial + Inclusive:** A person may or may not be a student or a worker, and can be both.

```
            ┌──────────┐
            │  Person  │
            └────┬─────┘
          Total / \ Exclusive
         ┌──────┐ ┌────────┐
         │Student│ │ Worker │
         └──────┘ └────────┘
```

---

### 1.2 Logical Design

The logical design phase takes the **E/R model** as input and produces a **relational model** as output.

#### Relation Schema

A **relation schema** (or simply a relation) is defined by the **name** of the relation and the **set of its attributes**. The underlined attribute identifies the key.

$$R(\underline{\text{attribute}_1}, \text{attribute}_2, \ldots, \text{attribute}_n)$$

#### Database Schema

A **database schema** is defined as the **set of all relation schemas**.

#### Relation Instance

A **relation instance** is the set of all **tuples** belonging to a relation schema. A tuple is a function that maps each attribute of a relation to a value from that attribute's domain.

#### Database Instance

A **database instance** is the set of all relation instances for all relations in the database schema.

#### Tuple Constraint

A tuple constraint limits the possible values of a tuple according to a logical condition.

**Example:** Given the relation `Student(StudentID, Grade, Name)`:

$$\text{Grade} \geq 18 \quad \text{AND} \quad \text{Grade} \leq 30$$

#### Key (Formal Definition)

> A set of attributes $K$ of a relation is a **key** if:
> 1. $K$ is a **superkey**
> 2. $K$ is **minimal** with respect to the property of being a superkey

> A set of attributes $K$ is a **superkey** if no two tuples $t_i$ and $t_j$ in the relation instance have the same value for $K$:
>
> $$t_i[K] \neq t_j[K] \iff t_i, t_j \in R$$

#### Foreign Key

A **foreign key constraint** is a constraint between a set $X$ of attributes of a relation $R_1$ and a relation $R_2$. For every instance of $R_1$, the values present in $X$ for each tuple must exist as a primary key value in the instance of $R_2$.

When the foreign key is defined over more than one attribute, an ordering must be defined on both $X$ and $Y$ (the key of $R_2$), and each value in $X$ must correspond in order to a value in $Y$.

#### Translating Relationships

When translating E/R relationships into the relational model, the approach depends on the **cardinality**. Foreign keys are omitted below for brevity. An asterisk `*` means the attribute can be `NULL`.

**Many-to-Many (N:M):**

```
E1(Ae11, Ae12)
E2(Ae21, Ae22)
R(Ae11, Ae21, Ar)       -- Separate relationship table
```

**One-to-Many (1:N) — Mandatory:**

```
E1(Ae11, Ae12, Ae21, Ar) -- Foreign key absorbed into the "many" side
E2(Ae21, Ae22)
```

**One-to-Many (1:N) — Optional:**

```
E1(Ae11, Ae12, Ae21*, Ar*) -- Nullable foreign key on the "many" side
E2(Ae21, Ae22)
```

**One-to-One (1:1) — Mandatory:**

```
E1(Ae11, Ae12, Ae21, Ar)   -- Merge into one side
E2(Ae21, Ae22)
```

**One-to-One (1:1) — Optional (single side):**

```
E1(Ae11, Ae12, Ae21, Ar)   -- Always merge from the 1:1 side
E2(Ae21, Ae22)
```

**One-to-One (1:1) — Optional (both sides):**

```
E1(Ae11, Ae12, Ae21*, Ar*) -- Nullable foreign key on either side
E2(Ae21, Ae22)
```

#### Translating Generalizations

There are three methods for translating generalizations into the relational model:

| Method | Description |
|--------|-------------|
| **Merge children into parent** | Add a discriminating attribute to identify which child type. Child-specific attributes become nullable. |
| **Merge parent into children** | All parent attributes are duplicated into each child relation. |
| **Replace with association** | Transform the generalization into relationships: 0:1 from the parent side and 1:1 with a fully external key from the child side. |

---

### 1.3 Physical Design

Physical design takes the **database schema** as input and produces a **physical schema** — i.e. how data is actually stored on disk. This topic is covered in depth in the [Storage Organization](#4-storage-organization-physical-design) section below.

---

## 2. Relational Algebra

Relational algebra is the **mathematical foundation** underlying SQL and database query processing. It defines a set of operators that take relations as input and produce relations as output.

### 2.1 Operator Properties

Two key properties of relational algebra operators:

| Property | Description |
|----------|-------------|
| **Monadic** | An operator that takes a single argument (one relation) |
| **Reentrant** | An operator that returns a result of the same type as its input — takes a relation, returns a relation |

The reentrant property is what makes relational algebra so powerful: you can **chain operators** together, composing complex queries from simple building blocks.

---

### 2.2 Selection (σ)

The **selection** operator takes a relation and a predicate function $f$, and returns a new relation containing only the tuples that satisfy $f$.

$$\sigma_{f}(R)$$

**Example:** Select all people older than 21:

$$\sigma_{\text{age} > 21}(\text{Person})$$

---

### 2.3 Projection (π)

The **projection** operator takes a relation and a list of attributes, and returns a new relation projected onto only those attributes.

$$\pi_{\text{attr}_1, \text{attr}_2, \ldots}(R)$$

**Example:** Get only the name and age of each person:

$$\pi_{\text{Name, Age}}(\text{Person})$$

---

### 2.4 Join (⋈)

The **join** operator filters the Cartesian product of two relations according to a given condition.

$$R \bowtie_{R.id = S.id} S$$

This is arguably the most important operator in relational algebra — it lets you combine data from multiple relations based on matching keys.

---

### 2.5 Rename (ρ)

The **rename** operator changes the name of an attribute in a relation.

$$\rho_{\text{OriginalName} \to \text{NewName}}(\text{Relation})$$

---

### 2.6 Set Operations

Since relations are fundamentally **sets**, the standard set operations are supported:

| Operation | Description |
|-----------|-------------|
| **Union** ($\cup$) | Combines tuples from both relations |
| **Difference** ($-$) | Tuples in the first relation but not in the second |
| **Intersection** ($\cap$) | Tuples present in both relations |
| **Cartesian Product** ($\times$) | All possible pairs of tuples from two relations |

---

## 3. SQL (MySQL)

SQL (Structured Query Language) is the practical language used to interact with relational databases. This section covers the most common SQL operations using MySQL syntax.

### 3.1 Defining a Database Schema

```sql
CREATE DATABASE databaseName;
```

### 3.2 Defining a Relation (Table)

```sql
CREATE TABLE tableName (
    attribute1 datatype constraint,
    attribute2 datatype constraint
);
```

### 3.3 Inserting Tuples

Insert with specific columns:

```sql
INSERT INTO table_name (column1, column2, column3)
VALUES (value1, value2, value3);
```

Insert with all values:

```sql
INSERT INTO table_name
VALUES (value1, value2, value3);
```

### 3.4 Deleting Tuples

```sql
DELETE FROM table_name WHERE condition;
```

### 3.5 SELECT (Projection)

The `SELECT` statement works like the **projection** operator in relational algebra. The `FROM` clause specifies which table to query.

```sql
SELECT CustomerName, City
FROM Customers;
```

Use `DISTINCT` to eliminate duplicates:

```sql
SELECT DISTINCT CustomerName, City
FROM Customers;
```

### 3.6 WHERE (Selection)

The `WHERE` clause filters tuples from the table specified in `FROM` according to a condition — analogous to the **selection** operator.

```sql
SELECT C1.CustomerName, C1.City
FROM Customers
WHERE Customers.City = 'Roma';
```

### 3.7 JOIN

The `JOIN` operation works just like the join in relational algebra:

```sql
SELECT C1.CustomerName
FROM Customers C1, City C2
WHERE C1.city = C2.cod;
```

### 3.8 Views

Views allow you to assign the result of an intermediate query to a virtual table:

```sql
CREATE VIEW view_name (column1, column2) AS
SELECT column1, column2
FROM table_name
WHERE condition;
```

### 3.9 IN / NOT IN

The `IN` operator checks whether attribute values in a column belong to a given set or the result of a subquery:

```sql
SELECT *
FROM Customers
WHERE Country IN ('Germany', 'France', 'UK');
```

```sql
SELECT *
FROM Customers
WHERE CustomerID IN (
    SELECT Orders.CustomerID
    FROM Orders
);
```

`NOT IN` checks for the absence of values.

### 3.10 EXISTS / NOT EXISTS

`EXISTS` returns **true** if the subquery returns at least one tuple. `NOT EXISTS` returns **true** if the subquery returns no tuples.

```sql
SELECT SupplierName
FROM Suppliers
WHERE EXISTS (
    SELECT ProductName
    FROM Products
    WHERE Products.SupplierID = Suppliers.SupplierID
      AND Price = 22
);
```

### 3.11 Aggregate Functions

Aggregate functions perform calculations across a set of rows. **Important rule:** if a `SELECT` contains aggregate functions, it can *only* contain aggregates (no regular attributes, unless they appear in a `GROUP BY`).

| Function | Description |
|----------|-------------|
| `AVG(column)` | Returns the average of all values |
| `MAX(column)` | Returns the maximum value |
| `MIN(column)` | Returns the minimum value |
| `SUM(column)` | Returns the sum of all values |
| `COUNT(column)` | Returns the number of values. Use `COUNT(DISTINCT attr)` to exclude duplicates |

**Examples:**

```sql
SELECT AVG(Price) FROM Products;
SELECT MAX(Price) FROM Products;
SELECT MIN(Price) FROM Products;
SELECT SUM(Price) FROM Products;
SELECT COUNT(Price) FROM Products;
```

### 3.12 GROUP BY

`GROUP BY` groups rows that have the same value in the specified column. It is often combined with aggregate functions. **Rule:** any non-aggregate attribute in the `SELECT` must be part of the `GROUP BY`.

```sql
SELECT SUM(CustomerID), Country
FROM Customers
GROUP BY Country;
```

### 3.13 HAVING

`HAVING` acts like a `WHERE` clause, but specifically for **aggregate results**. It always appears together with `GROUP BY`.

```sql
SELECT COUNT(CustomerID), Country
FROM Customers
GROUP BY Country
HAVING COUNT(CustomerID) > 5;
```

### 3.14 ORDER BY

`ORDER BY` sorts query results in ascending (`ASC`) or descending (`DESC`) order.

```sql
SELECT *
FROM Products
ORDER BY Price ASC;
```

---

## 4. Storage Organization (Physical Design)

This section covers the **physical design** of databases — how tuples are actually stored on **secondary memory** (disk) to guarantee persistence (non-volatility).

**Organizing tuples in memory by key** means associating — through a function — the key of a tuple to the page that contains it.

Organization can be classified along two dimensions:

| Dimension | Options | Description |
|-----------|---------|-------------|
| **Role** | **Primary** | Imposes a criterion for *where* data is stored (e.g., tuple $t_1$ goes into page $p_1$) |
| | **Secondary** | Simply enables fast *retrieval* of data (e.g., $t_1$ is found in $p_1$) |
| **Adaptability** | **Static** | The organization remains fixed regardless of data volume |
| | **Dynamic** | The organization adapts to the number of tuples being stored |

---

### 4.1 Magnetic Disks

A magnetic disk storage device is composed of a set of disks magnetized on both surfaces. A **read-write head** attached to an arm accesses any position on any disk. A disk is logically divided into **sectors** and **tracks**. The pair ⟨sector, track⟩ identifies a **block** of fixed size (measured in bytes). All blocks have the same size.

```
            ┌─────────────────────┐
            │    Magnetic Disk    │
            │                     │
            │  Track ──┐          │
            │          │          │
            │    ┌─────┼─────┐    │
            │    │  Sector   │    │
            │    │   Block   │    │
            │    └───────────┘    │
            │                     │
            │   ← Read/Write →   │
            │      Head           │
            └─────────────────────┘
```

---

### 4.2 Primary Key Organization

#### 4.2.1 Static Hashing

Hashing is a **procedural, static** key organization technique.

A **hash function** maps each key to the page that contains it. Unlike in-memory hash tables, a page can contain **multiple keys** up to a maximum determined by the page size.

The commonly used hash function is:

$$H(k) = k \mod M$$

where $M$ is the total number of pages.

A **collision** occurs when we try to assign a key to a page that is already full.

**Collision handling strategies:**

| Strategy | Description |
|----------|-------------|
| **Overflow list** | A linked list of overflow pages |
| **Open addressing** | Probe for the next available slot |

Open addressing variants:

| Variant | Problem |
|---------|---------|
| **Linear probing** | Suffers from *primary clustering* — groups of adjacent keys form clusters |
| **Quadratic probing** | Suffers from *secondary clustering* — equal keys end up in the same position |
| **Double hashing** | Uses a second hash function to determine the probe step |

**Disadvantages of static hashing:**
- Cannot perform **range searches**
- **Static allocation** — fixed number of pages

---

#### 4.2.2 Virtual Hashing

Virtual hashing is a **procedural, dynamic** key organization technique.

**How it works:**

1. Allocate $M$ pages with capacity $C$, using hash function:

$$H_r(k) = k \mod (M \times 2^r)$$

where $r$ is the number of doublings performed so far (initially $r = 0$).

2. Allocate a binary vector $\varsigma$ of size $M$, initialized to all zeros. $\varsigma[i] = 1$ only when page $i$ contains a key.

3. Insert keys using the hash function. When a key is inserted into a page, the corresponding position in $\varsigma$ is set to 1.

**Collision handling:**

1. **Double** the size of both $\varsigma$ and the key vector.
2. **Update** the hash function by incrementing $r$: $\quad r = r + 1$
3. **Redistribute** keys from the overflowed page (and the new key) using the updated hash function.

**Advantages:**
- Single memory access for page retrieval thanks to vector $\varsigma$

**Disadvantages:**
- Must always double the entire vector
- Overflowed keys always end up either in the **old position** or **M positions ahead** — leading to wasted pages

---

#### 4.2.3 Extendible Hashing

Extendible hashing is a **procedural, dynamic** technique **without auxiliary structures**.

**How it works:**

1. Allocate a directory vector $\varsigma$ containing two cells. Unlike virtual hashing (which indicates whether a page contains a key), each cell stores a **pointer to a data area** containing the key.

$$\varsigma[\text{pseudo-key}] = \text{data area containing the key}$$

The pseudo-key is determined by a hash function $H(k) = \text{pseudo-key}$.

2. The directory has a **global prefix** $p$, and each data page has a **local prefix** $p'$.

3. Insert keys using the hash function.

**Collision handling:**

| Condition | Action |
|-----------|--------|
| $p = p'$ | **Double** the directory by cloning old pointers. Increase $p = p + 1$ |
| $p \neq p'$ | **Add a new page**. Increase $p' = p' + 1$ for both old and new pages |

Then:
- **Redistribute** overflowed keys between old and new pages based on the $(p'+1)$-th bit
- **Update** the cloned pointers to point to the new page

**Advantages:**
- Page retrieval in only **two memory accesses**

**Disadvantages:**
- No range search support

---

#### 4.2.4 Linear Hashing

Linear hashing is a **procedural, dynamic** technique.

**How it works:**

1. Allocate $M$ pages with capacity $C$.
2. Initialize a variable $p = 0$ that counts the number of overflows so far.
3. Insert keys using $H(k) = k \mod M$.

**Collision handling:**

1. Add a new page at address $p + M$ and create an **overflow list** at the overflowed cell.
2. Redistribute keys at position $p$ using $h(k) = k \mod 2M$.
3. Increment $p = p + 1$.

**Advantages:**
- Avoids the wasted-space problem of virtual hashing

**Disadvantages:**
- No range search support

---

#### 4.2.5 B-Trees

B-trees are **tree-based** primary key organization structures.

A **B-tree** is an $n$-ary tree that satisfies the following properties:

| Property | Description |
|----------|-------------|
| **Node = Page** | Each node corresponds to one disk page |
| **Header** | Each node contains a fixed-size header |
| **Cell contents** | Each cell stores pointers to children and a pointer to the tuple for its key |
| **Max children** | Each node can have at most $M$ children |
| **Balanced** | All leaf nodes are at the same level |
| **Ordered** | Keys within a node maintain sorted order: $k_1 < k_2 < \ldots < k_m$, and this holds recursively for children |
| **Children count** | A non-leaf node with $k$ keys must have exactly $k + 1$ children |
| **Min fill** | Every non-root node must have a minimum fill of $\lceil M/2 \rceil - 1$ keys |

**Height bound:**

$$h \leq \log_{\lceil M/2 \rceil}\left(\frac{n+1}{2}\right)$$

```
                    ┌───────────┐
                    │  30 | 70  │           ← Root
                    └─┬────┬──┬─┘
               ┌──────┘    │  └──────┐
          ┌────┴────┐ ┌────┴────┐ ┌──┴──────┐
          │ 10 | 20 │ │ 40 | 50 │ │ 80 | 90 │  ← Leaves
          └─────────┘ └─────────┘ └─────────┘
```

**Advantages:**
- All operations have **logarithmic cost**: $O(\log n)$

---

#### 4.2.6 B⁺-Trees

B⁺-trees are a variant of B-trees. The properties are the same, but with one critical difference:

> Internal nodes store **only keys and child pointers** — they do **not** store pointers to the actual data records. Only **leaf nodes** contain pointers to the tuples, and the leaves are linked together as a **bidirectional linked list**.

```
            ┌────────────┐
            │   30 | 70   │              ← Internal (keys + child ptrs only)
            └──┬────┬──┬──┘
         ┌─────┘    │  └─────┐
    ┌────┴────┐ ┌───┴────┐ ┌─┴────────┐
    │10|20| → │ │40|50| → │ │80|90|NULL│  ← Leaves (keys + data ptrs + next/prev)
    └─────────┘ └────────┘ └──────────┘
```

**Advantages:**
- Logarithmic cost operations **and** support for **range queries** (by traversing the leaf linked list)

---

### 4.3 Secondary Key Organization — Indexes

Secondary key organization is achieved through **indexes**.

#### What is an Index?

An **index** is a data structure that maps each search key to the tuple(s) that contain it.

#### Clustered Index

A **clustered index** maintains both the **physical** and **logical** order of search keys within the index. Generally, in most DBMSs, the **primary key** is associated with a clustered index.

#### Non-Clustered Index

A **non-clustered index** is a data structure that maps each search key (or group of search keys) to the tuples that contain it, **without imposing physical ordering**.

#### Advantages

- **Speed up search operations** dramatically

#### Disadvantages

- Can **slow down** insert, update, and delete operations (because the index must also be updated)
- Indexes are **stored on disk** too — they consume storage space

---

## 5. Transactions

A **transaction** is a set of instructions that, when executed correctly, changes the state of the database.

### 5.1 ACID Properties

Transactions must satisfy four fundamental properties, known as **ACID**:

| Property | Description |
|----------|-------------|
| **Atomicity** | A transaction is an atomic operation — either it executes entirely, or if interrupted, all changes are rolled back |
| **Consistency** | A transaction must leave the database in a consistent state (all constraints satisfied), whether it succeeds or fails |
| **Isolation** | A transaction must operate as if it were isolated from all other transactions |
| **Durability** | The effects of a successfully committed transaction must persist permanently |

---

#### Guaranteeing Atomicity — Rollback

When a transaction is **aborted** (terminates with a failure), a **rollback** operation must restore the database to the state it had before the transaction began.

Rollback is made possible by a **log file** that records:
- The value of each variable **before** and **after** each operation
- The **transaction ID** responsible for the modification

#### Guaranteeing Durability — Commit

**Durability** is guaranteed by the **commit** operation. Once a commit is executed, the effects of the transaction are permanent and cannot be rolled back.

#### Guaranteeing Isolation — Locks

**Isolation** is maintained through **locking mechanisms**, discussed in detail below.

#### Guaranteeing Consistency — Serial Execution

To guarantee consistency, transactions should ideally be executed **in series**. However, as we will see, **serializability** allows concurrent execution while preserving consistency.

---

### 5.2 Scheduler and Schedule

We stated that transactions should be executed in series to maintain consistency. However, serial execution is not efficient — allowing **concurrent execution** of transactions improves both **throughput** and **response time** (considering that the CPU is allocated to transactions in a round-robin fashion).

To prevent errors from concurrent execution, we use the concept of **serializability**.

> A **scheduler** is an algorithm that produces a **schedule**.
>
> A **schedule** is a sequence defining the **execution order** of instructions from multiple concurrent transactions.

---

### 5.3 Schedule Recoverability

If a transaction is aborted, its changes must be rolled back. For this to be possible, a schedule must be **recoverable**.

> **Recoverable schedule:** For every pair of transactions $T_i$ and $T_j$, if $T_j$ reads a value written by $T_i$, then the commit of $T_i$ must occur **before** the commit of $T_j$.

However, recoverability alone can lead to **cascading rollbacks** (inefficient chain reactions). To prevent this:

> **Cascadeless schedule:** For every pair of transactions $T_i$ and $T_j$, if $T_j$ reads a value written by $T_i$, then the commit of $T_i$ must occur **before** the read of $T_j$.

$$\text{Cascadeless} \implies \text{Recoverable}$$

---

### 5.4 Serializability

> A schedule $S$ is **serializable** if it is **equivalent** to some serial schedule $S_2$.

#### Equivalence

> Two schedules are **equivalent** when, for every database instance, schedule $S_1$ brings the database to the **same state** as $S_2$.

#### Conflict Serializability (CS)

**Conflict serializability** is a subset of serializability.

**Conflicting instructions:** Two instructions are in conflict when:
1. They belong to **different transactions**
2. They are executed **one after another**
3. They operate on the **same data item**
4. At least one of them is a **write operation**

> **Conflict equivalent:** Two schedules are conflict equivalent if $S_1$ can be transformed into $S_2$ by **swapping non-conflicting operations**.
>
> $$S_1 \Rightarrow_c S_2$$

> **Conflict serializable:** A schedule is conflict serializable if it is conflict equivalent to a **serial schedule**.
>
> $$S_1 \Rightarrow_c S_2 \quad \text{where } S_2 \text{ is serial}$$

**How to determine if a schedule is CS:**

Use the **precedence graph** and the **topological sort algorithm**:

1. **Precedence graph:** A directed graph where nodes are transactions and edges represent conflicting operations
2. **Topological sort:** If the graph has **no cycles**, the schedule is conflict serializable

```
  T1 ──────→ T2       ← No cycle: CS ✓
      write(A)

  T1 ──────→ T2
      ↑       │
      └───────┘        ← Cycle: NOT CS ✗
```

#### View Serializability (VS)

**View serializability** is another subset of serializability (and a superset of conflict serializability).

> **View equivalent:** Two schedules $S_1$ and $S_2$ are view equivalent ($S_1 \Rightarrow_v S_2$) if for every data item $Q$:
>
> 1. If $T_i$ reads the **initial value** of $Q$ in $S_1$, then $T_i$ reads the initial value of $Q$ in $S_2$
> 2. If $T_i$ writes the **final value** of $Q$ in $S_1$, then $T_i$ writes the final value of $Q$ in $S_2$
> 3. If $T_i$ reads the value of $Q$ written by $T_j$ in $S_1$, then $T_i$ reads the value of $Q$ written by $T_j$ in $S_2$

> **View serializable:** A schedule is view serializable if it is view equivalent to a serial schedule.

#### Serializability Hierarchy

$$\text{CS} \subset \text{VS} \subset \text{Serializable}$$

---

### 5.5 Locks

Locks are the primary mechanism for maintaining **isolation** and **mutual exclusion** on data items.

#### Lock-S (Shared Lock)

Allows **reading** the data item. Multiple transactions can hold a shared lock on the same item simultaneously, but **writes are blocked**.

#### Lock-X (Exclusive Lock)

Allows **writing** to the data item. No other transaction can read or write the data item while an exclusive lock is held.

| | Lock-S held | Lock-X held |
|---|---|---|
| **Request Lock-S** | ✅ Granted | ❌ Denied |
| **Request Lock-X** | ❌ Denied | ❌ Denied |

---

#### 2PL (Two-Phase Locking) Protocol

The **2PL protocol** restricts lock acquisition and release to two distinct phases:

| Phase | Rule |
|-------|------|
| **Growing Phase** | Transaction acquires all needed locks. No lock can be released. |
| **Shrinking Phase** | Transaction releases locks. No new lock can be acquired. |

> **Theorem:** If all transactions in a schedule follow 2PL, then the schedule is **conflict serializable** (and therefore serializable).

⚠️ 2PL does **not** guarantee cascadelessness.

---

#### S2PL (Strict Two-Phase Locking)

A variant of 2PL where **exclusive locks (Lock-X)** are only released **after the commit**.

$$\text{S2PL} \implies \text{Cascadeless}$$

---

#### R2PL (Rigorous Two-Phase Locking)

A variant of 2PL where **all locks** (both shared and exclusive) are only released **after the commit**.

$$\text{R2PL} \implies \text{Transactions are serial in commit order}$$

---

#### Locking Protocol Hierarchy

```
    R2PL (most restrictive — serial in commit order)
      │
      ▼
    S2PL (guarantees cascadelessness)
      │
      ▼
    2PL  (guarantees conflict serializability)
```

---

## Conclusion

Understanding how databases work under the hood is essential knowledge for any software engineer. In this post we covered the full journey:

1. **Database design** moves through three phases — conceptual (E/R modeling), logical (relational schema), and physical (disk storage).
2. **Relational algebra** provides the mathematical foundation: selection, projection, join, rename, and set operations.
3. **SQL** translates these algebraic concepts into a practical query language with `SELECT`, `WHERE`, `JOIN`, aggregates, `GROUP BY`, and more.
4. **Storage organization** determines how data physically lives on disk — from simple hashing to sophisticated B⁺-trees and indexes.
5. **Transactions** ensure data integrity through ACID properties, serializability guarantees, and locking protocols.

The next time you run a query, you will know exactly what is happening — from the SQL parser all the way down to the disk blocks and lock managers that make it all work.

---

> 📚 *These notes are based on my university database theory course material (December 2023).*
