defmodule GenFSTTest do
  use ExUnit.Case, async: true
  doctest GenFST

  describe "Simple FSTs" do
    import GenFST
    test "with a non transducing rule" do
      fst = new()
      |> rule(["act", "ing"])
      
      assert {:ok, "acting"} == fst |> parse("acting")
    end

    test "with equal length tranducing rule" do
      fst = new()
      |> rule([{"ate", "eat"}])
      
      assert {:ok, "eat"} == fst |> parse("ate")
    end

    test "rule with length of to greater than length of from" do
      fst = new()
      |> rule(["act", {"ed", "^ed"}])
      
      assert {:ok, "act^ed"} == fst |> parse("acted")
    end

    test "rule with length of to less than length of from" do
      fst = new()
      |> rule(["act", {"ing", ""}])
      
      assert {:ok, "act"} == fst |> parse("acting")
    end

    test "ambiguis rules" do
      fst = new()
      |> rule(["act", {"ing", ""}])
      |> rule(["act", {"ing", "e"}])
      |> rule([{"ate", "eat"}])

      assert {:ambigious, _} = fst |> parse("acting")
      assert {:ok, "eat"} = fst |> parse("ate")
    end
  end

  describe "integration testing" do
    fst = GenFST.new
    |> GenFST.rule(["play", {"s", "^s"}])
    |> GenFST.rule(["act", {"s", "^s"}])
    |> GenFST.rule(["act", {"ed", "^ed"}])
    |> GenFST.rule(["act", {"ing", ""}])

    assert {:ok, "play^s"} == fst |> GenFST.parse("plays")
  end

end
