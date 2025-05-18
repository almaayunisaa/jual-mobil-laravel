@extends('layouts.app')

@section('content')
<div class="bg-white shadow-sm py-3 px-4 mb-4 border-bottom">
        <h4 class="m-0 fw-bold">Daftar Kategori</h4>
</div>

<div class="container">
    <!-- Tombol untuk menambahkan kategori baru -->
    <a href="{{ route('categories.create') }}" class="btn btn-success mb-3">Tambah Kategori Baru</a>

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
                <th>Kategori</th>
                <th>Deskripsi</th>
                <th>Aksi</th>
            </tr>
        </thead>
        <tbody>
            @foreach($categories as $category)
            <tr>
                <td>{{ $category->name }}</td>
                <td>{{ $category->description }}</td>
                <td>
                    <a href="{{ route('categories.edit', $category->id) }}" class="btn btn-warning">Edit</a>
                    <form action="{{ route('categories.destroy', $category->id) }}" method="POST" style="display:inline;">
                        @csrf
                        @method('DELETE')
                        <button type="submit" class="btn btn-danger" onclick="return confirm('Apakah Anda yakin ingin menghapus kategori ini?')">Hapus</button>
                    </form>
                </td>
            </tr>
            @endforeach
        </tbody>
    </table>

    <!-- Menampilkan pagination -->
    {{ $categories->links() }}
</div>
@endsection

