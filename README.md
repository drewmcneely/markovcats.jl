# MarkovCats.jl
**A compositional toolkit and embedded DSL for discrete probability and Bayesian filtering in Julia**

MarkovCats.jl is a Julia library for expressing probabilistic models in a compact, algebraic, and highly compositional style. It provides an embedded DSL for discrete probability, backed by a semantic layer grounded in Markov categories. The frontend lets users write familiar probabilistic expressions; the backend interprets them in a chosen uncertainty representation, enabling eventual support for multiple algorithmic backends (e.g., discrete Bayes filters, Kalman filters, Gaussian message passing).

Users write *probability*; the library handles the categorical machinery behind the scenes.

---

## Background and Motivation

This project is connected with the ideas developed in  
**[Hidden Markov Models and the Bayes Filter in Categorical Probability](https://arxiv.org/abs/2401.14669)**.

MarkovCats.jl is also a spiritual successor to **[girypy](https://github.com/drewmcneely/girypy)**, an early Python prototype. This Julia library reimplements and extends those ideas with a macro-based syntactic frontend and a modular backend architecture.

---

## Features

### Current
- Embedded DSL for writing probabilistic equations
- Parsing into a compositional intermediate representation
- Construction of variable-typed port graphs
- Maximum-matching–based wiring of variables
- Preliminary backend evaluation for discrete probability

### In Development
- Conditional syntax
- Continuous and hybrid backends (Gaussian, linear-Gaussian)
- Recursive filtering pipelines (discrete + Kalman)
- Rewriting and normalization of diagrams
- Backend switching via a common Markov-category interface

MarkovCats.jl is in **early-stage development**, and APIs may evolve as the DSL and backend stabilize.

---

## The Embedded DSL

The DSL allows writing probability equations in near-mathematical notation. Macros desugar these expressions into canonical kernel lists, build computational graphs, and prepare them for backend interpretation.

### Example: Chapman–Kolmogorov Equation

```julia
@kernelassignments begin
    py(y) = sum(x)( f(y|x) * p(x) )
end
```

### Example: Independent Joint Distribution

```julia
@kernelassignments begin
    pxy(x, y) = px(x) * py(y)
end
```

### Additional Examples (Possible with Current Syntax)

#### Deterministic Transformation

```julia
@kernelassignments begin
    py(y) = f(y | x) * px(x)
end
```

#### Multi-variable Marginalization

```julia
@kernelassignments begin
    pz(z) = sum(x, y)( h(z | x, y) * px(x) * py(y) )
end
```

#### Copy Structure

```julia
@kernelassignments begin
    pxx(x1, x2) = copy(x)(x1, x2) * px(x)
end
```

---

## Pipeline Overview

MarkovCats.jl uses a multi-stage pipeline to convert surface-level probability syntax into executable algorithms.

### 1. **Syntactic Frontend (Macros)**
User-facing macros parse expressions such as:
```julia
py(y) = sum(x)( f(y|x) * p(x) )
```
into an AST annotated with kernel structure, variable declarations, and summation scopes.

### 2. **Intermediate Representation (KernelList)**
The AST is lowered into a uniform IR:
- A boundary kernel (the LHS)
- A sequence of interior kernels
- Automatically inserted `copy(v)` kernels for duplicated variables

This IR resembles a string diagram in a Markov category.

### 3. **Port Graph Construction**
Each kernel becomes a node with input and output “ports,” typed by variables. Edges connect ports that could match based on variable names.

### 4. **Maximum-Cardinality Matching**
A matching algorithm selects a consistent pairing of input/output ports to form a valid diagram wiring.  
This chooses the *unique canonical factorization* implied by the user's equation.

### 5. **Diagram Simplification**
Redundant identities or copies are removed, and the diagram is normalized.

### 6. **Backend Interpretation**
The finalized diagram is executed in the chosen backend:
- Discrete probability table operations
- Linear-Gaussian updates (planned)
- Alternative uncertainty models (future)

Different backends implement a common interface, making the DSL backend-agnostic.

---

## Vision

Eventually, the same equation:

```julia
@kernelassignments py(y) = sum(x)( f(y|x) * p(x) )
```

will produce:
- a discrete Bayes filter when interpreted in the discrete backend,
- a Kalman filter when interpreted in a Gaussian backend,
- or any other filtering algorithm supported by the chosen uncertainty model.

Users write equations; MarkovCats.jl handles the interpretation.

---

## Installation

```julia
] add MarkovCats
```

(*Update once the package is registered.*)

---

## Status

MarkovCats.jl is actively evolving.  
Issues, discussions, and contributions are welcome.

---

## Roadmap

- [ ] Complete conditional syntax  
- [ ] Gaussian + hybrid backends  
- [ ] Automated diagram rewriting  
- [ ] Full recursive filtering examples  
- [ ] Tutorial notebooks and documentation  

---
