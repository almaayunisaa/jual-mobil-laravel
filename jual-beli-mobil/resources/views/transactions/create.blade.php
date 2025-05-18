@extends('layouts.app')

@section('content')
<!-- AppBar Putih -->
<div class="bg-white shadow-sm py-3 px-4 mb-4 border-bottom">
    <h4 class="m-0 fw-bold">Tambah Transaksi Baru</h4>
</div>

<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-6 bg-white p-4 shadow-sm rounded">
            <!-- Menampilkan error validasi jika ada -->
            @if ($errors->any())
                <div class="alert alert-danger">
                    <ul class="mb-0">
                        @foreach ($errors->all() as $error)
                            <li>{{ $error }}</li>
                        @endforeach
                    </ul>
                </div>
            @endif

            <!-- Form untuk menambahkan transaksi baru -->
            <form method="POST" action="{{ route('transactions.store') }}">
                @csrf

                <div class="mb-3">
                    <label for="customer_id" class="form-label">Pelanggan</label>
                    <select class="form-select" id="customer_id" name="customer_id" required>
                        <option value="">-- Pilih Pelanggan --</option>
                        @foreach($customers as $customer)
                            <option value="{{ $customer->id }}" {{ old('customer_id') == $customer->id ? 'selected' : '' }}>
                                {{ $customer->name }}
                            </option>
                        @endforeach
                    </select>
                </div>

                <div class="mb-3">
                    <label for="product_id" class="form-label">Produk</label>
                    <select class="form-select" id="product_id" name="product_id" required>
                        <option value="">-- Pilih Produk --</option>
                        @foreach($products as $product)
                            <option value="{{ $product->id }}" {{ old('product_id') == $product->id ? 'selected' : '' }}>
                                {{ $product->name }}
                            </option>
                        @endforeach
                    </select>
                </div>

                <div class="mb-3">
                    <label for="quantity" class="form-label">Jumlah Produk</label>
                    <input type="number" class="form-control" id="quantity" name="quantity"
                        value="{{ old('quantity', 1) }}" min="1" required>
                </div>

                <div class="mb-3">
                    <label for="transaction_date" class="form-label">Tanggal Transaksi</label>
                    <input type="date" class="form-control" id="transaction_date" name="transaction_date"
                        value="{{ old('transaction_date') }}" required>
                </div>

                <div class="d-flex justify-content-end">
                    <a href="{{ route('transactions.index') }}" class="btn btn-secondary me-2">Batal</a>
                    <button type="submit" class="btn btn-primary">Simpan</button>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection
