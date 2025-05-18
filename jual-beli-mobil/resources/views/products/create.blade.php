@extends('layouts.app')

@section('content')
<!-- AppBar Putih -->
<div class="bg-white shadow-sm py-3 px-4 mb-4 border-bottom">
    <h4 class="m-0 fw-bold">Tambah Produk Baru</h4>
</div>

<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-6 bg-white p-4 shadow-sm rounded">
            <!-- Menampilkan error validasi -->
            @if ($errors->any())
                <div class="alert alert-danger">
                    <ul class="mb-0">
                        @foreach ($errors->all() as $error)
                            <li>{{ $error }}</li>
                        @endforeach
                    </ul>
                </div>
            @endif

            <!-- Form Tambah Produk -->
            <form method="POST" action="{{ route('products.store') }}">
                @csrf

                <div class="mb-3">
                    <label for="name" class="form-label">Nama Produk</label>
                    <input type="text" class="form-control" id="name" name="name"
                           value="{{ old('name') }}" required>
                </div>

                <div class="mb-3">
                    <label for="description" class="form-label">Deskripsi Produk</label>
                    <textarea class="form-control" id="description" name="description" required>{{ old('description') }}</textarea>
                </div>

                <div class="mb-3">
                    <label for="price" class="form-label">Harga Produk</label>
                    <input type="number" class="form-control" id="price" name="price"
                           value="{{ old('price') }}" step="0.01" required>
                </div>

                <div class="mb-3">
                    <label for="category_id" class="form-label">Kategori Produk</label>
                    <select class="form-select" id="category_id" name="category_id" required>
                        <option value="">-- Pilih Kategori --</option>
                        @foreach($categories as $category)
                            <option value="{{ $category->id }}" {{ old('category_id') == $category->id ? 'selected' : '' }}>
                                {{ $category->name }}
                            </option>
                        @endforeach
                    </select>
                </div>

                <div class="d-flex justify-content-end">
                    <a href="{{ route('products.index') }}" class="btn btn-secondary me-2">Batal</a>
                    <button type="submit" class="btn btn-primary">Simpan</button>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection
