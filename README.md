# ![Elixir](https://hexdocs.pm/ex_unit/assets/logo.png) GenFST

[![Build Status](https://travis-ci.org/xiamx/gen_fst.svg?branch=master)](https://travis-ci.org/xiamx/gen_fst)
[![Hex.pm](https://img.shields.io/hexpm/v/gen_fst.svg)](https://hex.pm/packages/gen_fst)
[![license](https://img.shields.io/github/license/xiamx/gen_fst.svg)](https://github.com/xiamx/gen_fst/blob/master/LICENSE)

GenFST implements a generic finite state transducer with
customizable rules expressed in a DSL.

A finite-state transducer (FST) is a finite-state machine 
with two memory tapes, following the terminology for Turing 
machines: an input tape and an output tape.

A FST will read a set of strings on the input tape and 
generates a set of relations on the output tape. An FST 
can be thought of as a translator or relater between strings in a set.

In morphological parsing, an example would be inputting a string of letters 
into the FST, the FST would then output a string of 
[morphemes](https://en.wikipedia.org/wiki/Morphemes).

## Features

- **Core FST Operations**: Create and configure finite state transducers
- **Batch Processing**: Process multiple inputs efficiently with `parse_batch/2`
- **Parsing Utilities**: Check parsing capability with `can_parse?/2`
- **Statistics**: Get detailed FST information with `stats/1`
- **Comprehensive Error Handling**: Clear error messages and ambiguity detection
- **Type Safety**: Full type specifications for all functions

## Example

Here we implement a simple morphological parser for English language. This
morphological parser recognizes different inflectional morphology of the verbs.

```elixir
fst = GenFST.new
|> GenFST.rule(["play", {"s", "^s"}])
|> GenFST.rule(["act", {"s", "^s"}])
|> GenFST.rule(["act", {"ed", "^ed"}])
|> GenFST.rule(["act", {"ing", ""}])

# Single parsing
{:ok, "play^s"} = GenFST.parse(fst, "plays")

# Batch processing
results = GenFST.parse_batch(fst, ["plays", "acted", "invalid"])
# [{:ok, "play^s"}, {:ok, "act^ed"}, {:error, "not possible"}]

# Check parsing capability
true = GenFST.can_parse?(fst, "plays")
false = GenFST.can_parse?(fst, "invalid")

# Get FST statistics
%{vertex_count: 12, edge_count: 11, terminal_vertices: 4} = GenFST.stats(fst)
```

For example if we pass the third-person singular tense of the verb _act_,
`GenFST.parse(fst, "acts")`, the morphological parser will output
`{:ok, "act^s"}`. The semantic of rule definition is given at [`rule/2`](https://hexdocs.pm/gen_fst/GenFST.html#rule/2).

## Return Types

GenFST v0.5.0 uses explicit tagged tuples for better error handling:

- `{:ok, result}` - Successful parsing with single result
- `{:ambiguous, [results]}` - Multiple valid parsings found  
- `{:error, reason}` - Parsing failed

## Installation

The package can be installed by adding `gen_fst` to your list of 
dependencies in `mix.exs`:

```elixir
def deps do
  [{:gen_fst, "~> 0.5.0"}]
end
```

## Documentation

The docs for this project can be found at [https://hexdocs.pm/gen_fst](https://hexdocs.pm/gen_fst).

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for detailed release notes.

## What's New in v0.5.0

- 🚀 **New Functions**: `parse_batch/2`, `can_parse?/2`, `stats/1`
- 🔧 **Better Error Handling**: Explicit tagged tuple returns
- 📊 **Enhanced Testing**: 14 comprehensive test cases
- 🛠️ **Developer Tools**: Credo, Dialyxir, formatter configuration
- 📚 **Improved Documentation**: Complete type specs and examples
- ⚡ **Modernized Dependencies**: Updated to latest versions

