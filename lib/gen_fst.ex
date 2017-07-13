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
  defmodule MorphologicalParser do
    use GenFST

    rule ["play", {"s", "^s"}]
    rule ["act", {"s", "^s"}]

  end
  assert MorphologicalParser.parse("plays") == "play^s"
  ```

  For example if we pass the third-person singluar tense of the verb _act_,
  `MorphologicalParser.parse("acts")`, the morphological parser will output
  `"act^s"`. The semantic of rule definition is given at `rule/1`.

  """

  defmacro __using__(_opts) do
    quote location: :keep do 
      @rules []
      @before_compile GenFST

      import GenFST
    end
  end

  @doc """
  Define a transducing rule.

  A transducing rule is a `List` of `String | {String, String}`.

  For example: `rule ["play", {"s", "^s"}]` means outputing `"play"` verbatimly,
  and transform `"s"` into `"^s"`. If a finite state transducer built with
  this rule is fed with string `"plays"`, then the output will be `"play^s"`
  """
  defmacro rule(r) do
    quote do 
      @rules [unquote(r) | @rules]
    end
  end

  @doc false
  def process_rule(fst_graph, rule) do
    {fst_graph, _, _} =  Enum.reduce(rule, {fst_graph, :root, ""}, fn(rule_item, {fst_graph, vertex, prefix}) ->
      process_rule_item(fst_graph, vertex, prefix, rule_item)
    end)
    fst_graph
  end

  @doc false
  def process_rule_item(fst_graph, vertex, prefix, rule_item) do
    if is_binary rule_item do
      Enum.reduce(String.codepoints(rule_item), {fst_graph, vertex, prefix}, fn(char, {fst_graph, vertex, prefix}) -> 
        process_rule_item_char(fst_graph, vertex, prefix, {char, char})
      end)
    else
      {from, to} = rule_item
      new_prefix = prefix <> from
      target_v = String.to_atom(new_prefix)
      edge = Graph.Edge.new(vertex, target_v, label: {from, to})
      fst_graph = fst_graph
      |> Graph.add_edge(edge)
      {fst_graph, target_v, new_prefix}
    end
  end

  @doc false
  def process_rule_item_char(fst_graph, vertex, prefix, {from, to}) do
    new_prefix = prefix <> from
    target_v = String.to_atom(new_prefix)
    edge = Graph.Edge.new(vertex, target_v, label: {from, to})
    fst_graph = fst_graph
    |> Graph.add_edge(edge)
    {fst_graph, target_v, new_prefix}
  end

  # Invoked right before target module compiled, used to inject
  # GenStateMachine event handlers.
  @doc false
  defmacro __before_compile__(_env) do
    quote location: :keep do
      @fst_graph Enum.reduce(@rules, Graph.new(), fn(rule, fst_graph) -> 
        fst_graph |> process_rule(rule)
      end)

      def transduce(alphabet, state, transduced) do
        edge = Enum.find(Graph.out_edges(@fst_graph, state), nil, fn(edge) -> 
          {e_from, e_to} = edge.label
          e_from == alphabet
        end)

        transduced = transduced <> elem(edge.label, 1)
        {edge.v2, transduced}
      end

      @initial_state_data {:root, ""}
      def parse(input) do
        input_cps = String.codepoints(input)
        {final_state, transduced} = Enum.reduce(input_cps, @initial_state_data, 
          fn(a, {state, transduced}) -> 
          transduce(a, state, transduced)
        end)
        transduced
      end
    end
  end
end