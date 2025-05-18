@extends('layouts.app')

@section('content')

<div class="bg-white shadow-sm py-3 px-4 mb-4 border-bottom">
    <h4 class="m-0 fw-bold">Daftar Pelanggan</h4>
</div>
<div class="container">

    <!-- Tombol untuk menambahkan Pelanggan baru -->
    <a href="{{ route('customers.create') }}" class="btn btn-success mb-3">Tambah Pelanggan Baru</a>

    <!-- Menampilkan pesan sukses jika ada -->
    @if(session('success'))
        <div class="alert alert-success">
            {{ session('success') }}
        </div>
    @endif

    <!-- Menampilkan tabel daftar pelanggan -->
    <table class="table table-bordered">
        <thead>
            <tr>
                <th>Nama</th>
                <th>Email</th>
                <th>No Telepon</th>
                <th>Alamat</th>
                <th>Aksi</th>
            </tr>
        </thead>
        <tbody>
            @foreach($customers as $customer)
            <tr>
                <td>{{ $customer->name }}</td>
                <td>{{ $customer->email }}</td>
                <td>{{ $customer->phone }}</td>
                <td>{{ $customer->address }}</td>
                <td>
                    <a href="{{ route('customers.edit', $customer->id) }}" class="btn btn-warning">Edit</a>
                    <form action="{{ route('customers.destroy', $customer->id) }}" method="POST" style="display:inline;">
                        @csrf
                        @method('DELETE')
                        <button type="submit" class="btn btn-danger" onclick="return confirm('Apakah Anda yakin ingin menghapus pelanggan ini?')">Hapus</button>
                    </form>
                </td>
            </tr>
            @endforeach
        </tbody>
    </table>

    <!-- Menampilkan pagination -->
    {{ $customers->links() }}
</div>
@endsection

