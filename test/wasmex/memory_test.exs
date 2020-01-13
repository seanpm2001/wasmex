defmodule Wasmex.MemoryTest do
  use ExUnit.Case, async: true
  doctest Wasmex.Memory

  defp build_wasm_instance do
    bytes = File.read!(TestHelper.wasm_file_path)
    Wasmex.Instance.from_bytes(bytes)
  end

  defp build_memory(size, offset) do
    {:ok, instance} = build_wasm_instance()
    Wasmex.Memory.from_instance(instance, size, offset)
  end

  describe "bytes_per_element/1" do
    test "returns number of bytes for uint8" do
      {:ok, memory} = build_memory(:uint8, 0)
      assert Wasmex.Memory.bytes_per_element(memory) == 1
    end

    test "returns number of bytes for int8" do
      {:ok, memory} = build_memory(:int8, 0)
      assert Wasmex.Memory.bytes_per_element(memory) == 1
    end

    test "returns number of bytes for uint16" do
      {:ok, memory} = build_memory(:uint16, 0)
      assert Wasmex.Memory.bytes_per_element(memory) == 2
    end

    test "returns number of bytes for int16" do
      {:ok, memory} = build_memory(:int16, 0)
      assert Wasmex.Memory.bytes_per_element(memory) == 2
    end

    test "returns number of bytes for uint32" do
      {:ok, memory} = build_memory(:uint32, 0)
      assert Wasmex.Memory.bytes_per_element(memory) == 4
    end

    test "returns number of bytes for int32" do
      {:ok, memory} = build_memory(:int32, 0)
      assert Wasmex.Memory.bytes_per_element(memory) == 4
    end
  end

  @page_size 65_536 # in bytes
  @initial_pages 17
  @min_memory_size @initial_pages * @page_size # in bytes

  describe "length/1" do
    test "returns number of uint8 elements that fit into memory" do
      {:ok, memory} = build_memory(:uint8, 0)
      assert Wasmex.Memory.length(memory) ==  @min_memory_size
    end

    test "returns number of uint16 elements that fit into memory" do
      {:ok, memory} = build_memory(:uint16, 0)
      assert Wasmex.Memory.length(memory) ==  @min_memory_size / 2
    end

    test "returns number of int32 elements that fit into memory" do
      {:ok, memory} = build_memory(:int32, 0)
      assert Wasmex.Memory.length(memory) ==  @min_memory_size / 4
    end
  end

  describe "grow/2" do
    test "grows the memory by the given number of pages" do
      {:ok, memory} = build_memory(:uint8, 0)
      assert Wasmex.Memory.length(memory) / @page_size ==  @initial_pages
      assert Wasmex.Memory.grow(memory, 3) == @initial_pages
      assert Wasmex.Memory.length(memory) / @page_size ==  @initial_pages + 3
      assert Wasmex.Memory.grow(memory, 1) == @initial_pages + 3
      assert Wasmex.Memory.length(memory) / @page_size ==  @initial_pages + 4
    end
  end

  describe "get/2 and set/3" do
    test "sets and gets uint8 values" do
      {:ok, memory} = build_memory(:uint8, 0)
      assert Wasmex.Memory.get(memory, 0) == 0
      :ok = Wasmex.Memory.set(memory, 0, 42)
      assert Wasmex.Memory.get(memory, 0) == 42
    end
  end
end
