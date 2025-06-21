defmodule GenFST do
  @moduledoc """
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

  ## Example

  Here we implement a simple morphological parser for English language. This
  morphological parser recognize different inflectional morphology of the verbs.

  ```elixir
  fst = GenFST.new
  |> GenFST.rule(["play", {"s", "^s"}])
  |> GenFST.rule(["act", {"s", "^s"}])
  |> GenFST.rule(["act", {"ed", "^ed"}])
  |> GenFST.rule(["act", {"ing", ""}])

  assert "play^s" == fst |> GenFST.parse("plays")
  ```

  For example if we pass the third-person singluar tense of the verb _act_,
  `GenFST.parse(fst, "acts")`, the morphological parser will output
  `"act^s"`. The semantic of rule definition is given at `rule/2`.

  """

  @opaque fst :: %Graph{}

  @doc """
  Create a new finite state transducer.

  See example usage in [Module Example](#module-example)
  """
  @spec new :: fst
  def new do
    Graph.new()
  end

  @doc """
  Define a transducing rule, adding it to the fst

  A transducing rule is a `List` of `String.t | {String.t, String.t}`.

  For example: `rule fst, ["play", {"s", "^s"}]` means outputing `"play"` verbatimly,
  and transform `"s"` into `"^s"`. If a finite state transducer built with
  this rule is fed with string `"plays"`, then the output will be `"play^s"`

  See example usage in [Module Example](#module-example)
  """
  @type fst_rule :: String.t() | {String.t(), String.t()}
  @spec rule(fst, [fst_rule]) :: fst
  def rule(fst, r) do
    process_rule(fst, r)
  end

  @doc """
  Parse the input by transducing it with the given fst.

  Returns:
  - `{:ok, result}` when exactly one transduction is possible
  - `{:ambiguous, [results]}` when multiple transductions are possible  
  - `{:error, reason}` when no transduction is possible

  See example usage in [Module Example](#module-example)
  """
  @spec parse(fst, String.t()) ::
          {:ok, String.t()} | {:ambiguous, [String.t()]} | {:error, String.t()}
  def parse(fst, input) do
    input_cps = String.codepoints(input)
    transduced = transduce(fst, input_cps, {:root, :initial}, "")
    transduced_len = Enum.count(transduced)

    cond do
      transduced_len == 0 ->
        {:error, "not possible"}

      transduced_len == 1 ->
        {:ok, List.first(transduced)}

      transduced_len > 1 ->
        {:ambiguous, transduced}
    end
  end

  @spec transduce(fst, [String.t()], tuple, String.t()) :: [String.t()]
  defp transduce(_fst_graph, [] = _input_cps, state, transduced) do
    if elem(state, 1) == :terminal do
      [transduced]
    else
      []
    end
  end

  defp transduce(fst_graph, [x | xs] = _input_cps, state, transduced) do
    edges =
      Enum.filter(Graph.out_edges(fst_graph, state), fn edge ->
        {e_from, _e_to} = edge.label
        e_from == x
      end)

    possible_transduced =
      for edge <- edges do
        transduce(fst_graph, xs, edge.v2, transduced <> elem(edge.label, 1))
      end

    List.flatten(Enum.filter(possible_transduced, fn result -> result != [] end))
  end

  @doc false
  @spec process_rule(fst, [fst_rule]) :: fst
  defp process_rule(fst_graph, rule) do
    rule_length = Enum.count(rule)

    {fst_graph, _, _} =
      Enum.reduce(Enum.with_index(rule), {fst_graph, {:root, :initial}, ""}, fn {rule_item, i},
                                                                                {fst_graph, vertex,
                                                                                 prefix} ->
        process_rule_item(fst_graph, vertex, prefix, rule_item, i == rule_length - 1)
      end)

    fst_graph
  end

  @doc false
  @spec process_rule_item(fst, tuple, String.t(), fst_rule, boolean) :: {fst, tuple, String.t()}
  defp process_rule_item(fst_graph, vertex, prefix, rule_item, is_terminal) do
    if is_binary(rule_item) do
      Enum.reduce(String.codepoints(rule_item), {fst_graph, vertex, prefix}, fn char,
                                                                                {fst_graph, vertex,
                                                                                 prefix} ->
        process_rule_item_char(fst_graph, vertex, prefix, {char, char}, is_terminal)
      end)
    else
      {from, to} = rule_item
      from_len = String.length(from)
      to_len = String.length(to)

      cond do
        from_len > to_len ->
          h_from = String.slice(from, 0, to_len)
          h_to = String.slice(to, 0, to_len)
          h_cps_pairs = Enum.zip(String.codepoints(h_from), String.codepoints(h_to))

          {fst_graph, vertex, prefix} =
            Enum.reduce(
              h_cps_pairs,
              {fst_graph, vertex, prefix},
              fn {from_cp, to_cp}, {fst_graph, vertex, prefix} ->
                process_rule_item_char(fst_graph, vertex, prefix, {from_cp, to_cp}, false)
              end
            )

          t_from_cps = String.codepoints(String.slice(from, to_len, from_len))
          t_from_cps_len = Enum.count(t_from_cps)

          Enum.reduce(
            Enum.with_index(t_from_cps),
            {fst_graph, vertex, prefix},
            fn {t_from_cp, i}, {fst_graph, vertex, prefix} ->
              process_rule_item_char(
                fst_graph,
                vertex,
                prefix,
                {t_from_cp, ""},
                t_from_cps_len - 1 == i and is_terminal
              )
            end
          )

        from_len < to_len ->
          h_from = String.slice(from, 0, from_len - 1)
          h_to = String.slice(to, 0, from_len - 1)
          h_cps_pairs = Enum.zip(String.codepoints(h_from), String.codepoints(h_to))

          {fst_graph, vertex, prefix} =
            Enum.reduce(
              h_cps_pairs,
              {fst_graph, vertex, prefix},
              fn {from_cp, to_cp}, {fst_graph, vertex, prefix} ->
                process_rule_item_char(fst_graph, vertex, prefix, {from_cp, to_cp}, false)
              end
            )

          process_rule_item_char(
            fst_graph,
            vertex,
            prefix,
            {
              String.slice(from, from_len - 1, from_len),
              String.slice(to, from_len - 1, to_len)
            },
            is_terminal
          )

        from_len == to_len ->
          cps_pairs = Enum.zip(String.codepoints(from), String.codepoints(to))
          cps_pairs_len = Enum.count(cps_pairs)

          Enum.reduce(
            Enum.with_index(cps_pairs),
            {fst_graph, vertex, prefix},
            fn {{from_cp, to_cp}, i}, {fst_graph, vertex, prefix} ->
              process_rule_item_char(
                fst_graph,
                vertex,
                prefix,
                {from_cp, to_cp},
                i == cps_pairs_len - 1 and is_terminal
              )
            end
          )
      end
    end
  end

  @doc false
  @spec process_rule_item_char(fst, tuple, String.t(), {String.t(), String.t()}, boolean) ::
          {fst, tuple, String.t()}
  defp process_rule_item_char(fst_graph, vertex, prefix, {from, to}, is_terminal) do
    new_prefix = prefix <> from

    target_v =
      if is_terminal do
        {new_prefix <> ":" <> to, :terminal}
      else
        {new_prefix <> ":" <> to, :transitional}
      end

    edge = Graph.Edge.new(vertex, target_v, label: {from, to})
    {Graph.add_edge(fst_graph, edge), target_v, new_prefix}
  end

  @doc """
  Parse multiple inputs with the given FST.

  Returns a list of results for each input.
  """
  @spec parse_batch(fst, [String.t()]) :: [term]
  def parse_batch(fst, inputs) when is_list(inputs) do
    Enum.map(inputs, &parse(fst, &1))
  end

  @doc """
  Check if the FST can parse the given input successfully.

  Returns `true` if parsing succeeds (regardless of ambiguity), `false` otherwise.
  """
  @spec can_parse?(fst, String.t()) :: boolean
  def can_parse?(fst, input) do
    case parse(fst, input) do
      {:ok, _} -> true
      {:ambiguous, _} -> true
      {:error, _} -> false
    end
  end

  @doc """
  Get statistics about the FST.

  Returns a map with information about the number of vertices and edges.
  """
  @spec stats(fst) :: map
  def stats(fst_graph) do
    vertices = Graph.vertices(fst_graph)
    edges = Graph.edges(fst_graph)

    %{
      vertex_count: Enum.count(vertices),
      edge_count: Enum.count(edges),
      terminal_vertices: Enum.count(vertices, fn v -> elem(v, 1) == :terminal end)
    }
  end
end
