<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use App\Models\Product;
use Illuminate\Http\Request;

class TransactionApiController extends Controller
{
    public function index()
    {
        $transactions = Transaction::with(['customer', 'product'])->paginate(10);
        return response()->json($transactions);
    }

    public function store(Request $request)
    {
        $request->validate([
            'customer_id' => 'required|exists:customers,id',
            'product_id' => 'required|exists:products,id',
            'quantity' => 'required|integer|min:1',
            'transaction_date' => 'required|date',
        ]);

        $product = Product::findOrFail($request->product_id);
        $totalPrice = $product->price * $request->quantity;

        $transaction = Transaction::create([
            'customer_id' => $request->customer_id,
            'product_id' => $request->product_id,
            'total_price' => $totalPrice,
            'transaction_date' => $request->transaction_date,
        ]);

        return response()->json([
            'message' => 'Transaksi berhasil ditambahkan',
            'transaction' => $transaction->load(['customer', 'product']),
        ], 201);
    }

    public function show($id)
    {
        $transaction = Transaction::with(['customer', 'product'])->findOrFail($id);
        return response()->json($transaction);
    }

    // Update transaksi berdasarkan ID
    public function update(Request $request, $id)
    {
        $request->validate([
            'customer_id' => 'required|exists:customers,id',
            'product_id' => 'required|exists:products,id',
            'quantity' => 'required|integer|min:1',
            'transaction_date' => 'required|date',
        ]);

        $product = Product::findOrFail($request->product_id);
        $totalPrice = $product->price * $request->quantity;

        $transaction = Transaction::findOrFail($id);
        $transaction->update([
            'customer_id' => $request->customer_id,
            'product_id' => $request->product_id,
            'total_price' => $totalPrice,
            'transaction_date' => $request->transaction_date,
        ]);

        return response()->json([
            'message' => 'Transaksi berhasil diupdate.',
            'transaction' => $transaction->load(['customer', 'product']),
        ]);
    }

    public function destroy($id)
    {
        $transaction = Transaction::findOrFail($id);
        $transaction->delete();

        return response()->json(['message' => 'Transaksi berhasil dihapus']);
    }
}
