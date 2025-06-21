defmodule GenFSTTest do
  use ExUnit.Case, async: true
  doctest GenFST

  describe "Simple FSTs" do
    import GenFST

    test "with a non transducing rule" do
      fst =
        new()
        |> rule(["act", "ing"])

      assert {:ok, "acting"} == fst |> parse("acting")
    end

    test "with equal length tranducing rule" do
      fst =
        new()
        |> rule([{"ate", "eat"}])

      assert {:ok, "eat"} == fst |> parse("ate")
    end

    test "rule with length of to greater than length of from" do
      fst =
        new()
        |> rule(["act", {"ed", "^ed"}])

      assert {:ok, "act^ed"} == fst |> parse("acted")
    end

    test "rule with length of to less than length of from" do
      fst =
        new()
        |> rule(["act", {"ing", ""}])

      assert {:ok, "act"} == fst |> parse("acting")
    end

    test "ambiguous rules" do
      fst =
        new()
        |> rule(["act", {"ing", ""}])
        |> rule(["act", {"ing", "e"}])
        |> rule([{"ate", "eat"}])

      assert {:ambiguous, _} = fst |> parse("acting")
      assert {:ok, "eat"} = fst |> parse("ate")
    end

    test "error case for non-parseable input" do
      fst =
        new()
        |> rule(["act", {"ing", ""}])

      assert {:error, "not possible"} = fst |> parse("xyz")
    end
  end

  describe "integration testing" do
    test "morphological parser example" do
      fst =
        GenFST.new()
        |> GenFST.rule(["play", {"s", "^s"}])
        |> GenFST.rule(["act", {"s", "^s"}])
        |> GenFST.rule(["act", {"ed", "^ed"}])
        |> GenFST.rule(["act", {"ing", ""}])

      assert {:ok, "play^s"} == fst |> GenFST.parse("plays")
      assert {:ok, "act^s"} == fst |> GenFST.parse("acts")
      assert {:ok, "act^ed"} == fst |> GenFST.parse("acted")
      assert {:ok, "act"} == fst |> GenFST.parse("acting")
    end
  end

  describe "new functionality" do
    test "parse_batch processes multiple inputs" do
      fst =
        GenFST.new()
        |> GenFST.rule(["play", {"s", "^s"}])
        |> GenFST.rule(["act", {"s", "^s"}])

      results = GenFST.parse_batch(fst, ["plays", "acts", "invalid"])

      assert [
               {:ok, "play^s"},
               {:ok, "act^s"},
               {:error, "not possible"}
             ] == results
    end

    test "can_parse? returns boolean" do
      fst =
        GenFST.new()
        |> GenFST.rule(["play", {"s", "^s"}])

      assert GenFST.can_parse?(fst, "plays") == true
      assert GenFST.can_parse?(fst, "invalid") == false
    end

    test "can_parse? returns true for ambiguous cases" do
      fst =
        GenFST.new()
        |> GenFST.rule(["act", {"ing", ""}])
        |> GenFST.rule(["act", {"ing", "e"}])

      assert GenFST.can_parse?(fst, "acting") == true
    end

    test "stats provides FST information" do
      fst =
        GenFST.new()
        |> GenFST.rule(["play", {"s", "^s"}])
        |> GenFST.rule(["act", {"s", "^s"}])

      stats = GenFST.stats(fst)

      assert is_map(stats)
      assert Map.has_key?(stats, :vertex_count)
      assert Map.has_key?(stats, :edge_count)
      assert Map.has_key?(stats, :terminal_vertices)
      assert stats.vertex_count > 0
      assert stats.edge_count > 0
      assert stats.terminal_vertices > 0
    end
  end

  describe "edge cases" do
    test "empty FST" do
      fst = GenFST.new()

      assert {:error, "not possible"} == GenFST.parse(fst, "test")
      assert GenFST.can_parse?(fst, "test") == false
    end

    test "empty input string" do
      fst =
        GenFST.new()
        |> GenFST.rule(["test"])

      assert {:error, "not possible"} == GenFST.parse(fst, "")
    end

    test "complex transformation rules" do
      fst =
        GenFST.new()
        |> GenFST.rule([{"running", "run^ing"}])
        |> GenFST.rule([{"better", "good^er"}])

      assert {:ok, "run^ing"} == GenFST.parse(fst, "running")
      assert {:ok, "good^er"} == GenFST.parse(fst, "better")
    end
  end
end
