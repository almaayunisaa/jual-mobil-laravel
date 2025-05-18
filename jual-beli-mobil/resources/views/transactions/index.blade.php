@extends('layouts.app')

@section('content')
<div class="bg-white shadow-sm py-3 px-4 mb-4 border-bottom">
        <h4 class="m-0 fw-bold">Daftar Transaksi</h4>
</div>

<div class="container">

    <!-- Tombol untuk menambahkan transaksi baru -->
    <a href="{{ route('transactions.create') }}" class="btn btn-success mb-3">Tambah Transaksi Baru</a>

    <!-- Menampilkan pesan sukses jika ada -->
    @if(session('success'))
        <div class="alert alert-success">
            {{ session('success') }}
        </div>
    @endif

    <!-- Menampilkan tabel daftar produk -->
    <table class="table table-bordered">
        <thead>
            <tr>
                <th>Pelanggan</th>
                <th>Produk</th>
                <th>Total Harga</th>
                <th>Tanggal Transaksi</th>
                <th>Aksi</th>
            </tr>
        </thead>
        <tbody>
            @foreach($transactions as $transaction)
            <tr>
                <td>{{ $transaction->customer->name }}</td>
                <td>{{ $transaction->product->name }}</td>
                <td>{{ $transaction->total_price }}</td>
                <td>{{ $transaction->transaction_date }}</td>
                <td>
                    <a href="{{ route('transactions.edit', $transaction->id) }}" class="btn btn-warning">Edit</a>
                    <form action="{{ route('transactions.destroy', $transaction->id) }}" method="POST" style="display:inline;">
                        @csrf
                        @method('DELETE')
                        <button type="submit" class="btn btn-danger" onclick="return confirm('Apakah Anda yakin ingin menghapus transaksi ini?')">Hapus</button>
                    </form>
                </td>
            </tr>
            @endforeach
        </tbody>
    </table>

    <!-- Menampilkan pagination -->
    {{ $transactions->links() }}
</div>
@endsection

