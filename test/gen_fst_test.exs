defmodule GenFSTTest do
  use ExUnit.Case, async: true
  doctest GenFST

  test "rule/1 should add a rule for processing later" do
    defmodule TestFST do
      use GenFST

      assert @rules == []

      r = ["act", {"ed", "^ed"}]
      rule r
      assert List.first(@rules) == r
    end
  end

  describe "process_rule/1" do
    test "process non-transduce rule" do
      r = ["act", "ing"]
      g = GenFST.process_rule(Graph.new, r)
      assert Graph.vertices(g) == [:a, :ac, :act, :acti, :root, :actin, :acting]
      assert Graph.edges(g) ==
      [%Graph.Edge{label: {"c", "c"}, v1: :a, v2: :ac, weight: 1},
      %Graph.Edge{label: {"t", "t"}, v1: :ac, v2: :act, weight: 1},
      %Graph.Edge{label: {"i", "i"}, v1: :act, v2: :acti, weight: 1},
      %Graph.Edge{label: {"n", "n"}, v1: :acti, v2: :actin, weight: 1},
      %Graph.Edge{label: {"a", "a"}, v1: :root, v2: :a, weight: 1},
      %Graph.Edge{label: {"g", "g"}, v1: :actin, v2: :acting, weight: 1}]
    end

    test "process equal length tranducing rule" do
      r = [{"ate", "eat"}]
      g = GenFST.process_rule(Graph.new, r)
      assert Graph.vertices(g) == [:a, :at, :ate, :root]
      assert Graph.edges(g) ==
      [%Graph.Edge{label: {"t", "a"}, v1: :a, v2: :at, weight: 1},
      %Graph.Edge{label: {"e", "t"}, v1: :at, v2: :ate, weight: 1},
      %Graph.Edge{label: {"a", "e"}, v1: :root, v2: :a, weight: 1}]
    end

    test "process rule with length of to greater than length of from" do
      r = ["act", {"ed", "^ed"}]
      g = GenFST.process_rule(Graph.new, r)
      assert Graph.vertices(g) == [:a, :ac, :act, :acte, :root, :acted]
      assert Graph.edges(g) ==
      [%Graph.Edge{label: {"c", "c"}, v1: :a, v2: :ac, weight: 1},
      %Graph.Edge{label: {"t", "t"}, v1: :ac, v2: :act, weight: 1},
      %Graph.Edge{label: {"e", "^"}, v1: :act, v2: :acte, weight: 1},
      %Graph.Edge{label: {"d", "ed"}, v1: :acte, v2: :acted, weight: 1},
      %Graph.Edge{label: {"a", "a"}, v1: :root, v2: :a, weight: 1}]
    end

    test "process rule with length of to less than length of from" do
      r = ["act", {"ing", ""}]
      g = GenFST.process_rule(Graph.new, r)
      assert Graph.vertices(g) == [:a, :ac, :act, :acti, :root, :actin, :acting]
      assert Graph.edges(g) ==
      [%Graph.Edge{label: {"c", "c"}, v1: :a, v2: :ac, weight: 1},
      %Graph.Edge{label: {"t", "t"}, v1: :ac, v2: :act, weight: 1},
      %Graph.Edge{label: {"i", ""}, v1: :act, v2: :acti, weight: 1},
      %Graph.Edge{label: {"n", ""}, v1: :acti, v2: :actin, weight: 1},
      %Graph.Edge{label: {"a", "a"}, v1: :root, v2: :a, weight: 1},
      %Graph.Edge{label: {"g", ""}, v1: :actin, v2: :acting, weight: 1}]
    end
  end

  describe "integration testing" do
    defmodule MorphologicalParser do
      use GenFST

      rule ["play", {"s", "^s"}]
      rule ["act", {"s", "^s"}]
      rule ["act", {"ed", "^ed"}]
      rule ["act", {"ing", ""}]

    end

    test "simple scenario with morph parsing" do
      assert MorphologicalParser.parse("plays") == "play^s"
      assert MorphologicalParser.parse("acts") == "act^s"
      assert MorphologicalParser.parse("acted") == "act^ed"
      assert MorphologicalParser.parse("acting") == "act"
    end
  end

end
