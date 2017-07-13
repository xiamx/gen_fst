defmodule GenFSTTest do
  use ExUnit.Case, async: true
  doctest GenFST

  test "rule/1 should add a rule for processing later" do
    defmodule TestFST do
      use GenFST

      assert @rules == []

      r = ["act", {"e", "^e"}, {"d", ""}]
      rule r
      assert List.first(@rules) == r
    end
  end

  test "process_rule/2 should process a given rule" do
    r = ["act", {"e", "^e"}, {"d", ""}]
    g = GenFST.process_rule(Graph.new, r)
    assert Graph.vertices(g) == [:a, :ac, :act, :acte, :root, :acted]
    assert Graph.edges(g) == [
      %Graph.Edge{label: {"c", "c"}, v1: :a, v2: :ac, weight: 1},
      %Graph.Edge{label: {"t", "t"}, v1: :ac, v2: :act, weight: 1},
      %Graph.Edge{label: {"e", "^e"}, v1: :act, v2: :acte, weight: 1},
      %Graph.Edge{label: {"d", ""}, v1: :acte, v2: :acted, weight: 1},
      %Graph.Edge{label: {"a", "a"}, v1: :root, v2: :a, weight: 1}
    ]
  end

    defmodule MorphologicalParser do
      use GenFST

      rule ["play", {"s", "^s"}]
      rule ["act", {"s", "^s"}]

    end

  test "simple scenario with morph parsing" do
    assert MorphologicalParser.parse("plays") == "play^s"
  end
end
