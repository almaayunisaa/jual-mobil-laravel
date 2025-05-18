@extends('layouts.app')

@section('content')
<!-- AppBar putih di atas -->
<div class="bg-white shadow-sm py-3 px-4 mb-4 border-bottom">
    <h4 class="m-0 fw-bold">Edit Pelanggan</h4>
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

            <!-- Form edit pelanggan -->
            <form method="POST" action="{{ route('customers.update', $customer->id) }}">
                @csrf
                @method('PUT')

                <div class="mb-3">
                    <label for="name" class="form-label">Nama Pelanggan</label>
                    <input type="text" class="form-control" id="name" name="name"
                        value="{{ old('name', $customer->name) }}" required>
                </div>

                <div class="mb-3">
                    <label for="email" class="form-label">Email</label>
                    <input type="email" class="form-control" id="email" name="email"
                        value="{{ old('email', $customer->email) }}" required>
                </div>

                <div class="mb-3">
                    <label for="phone" class="form-label">No Telepon</label>
                    <input type="text" class="form-control" id="phone" name="phone"
                        value="{{ old('phone', $customer->phone) }}" required>
                </div>

                <div class="mb-3">
                    <label for="address" class="form-label">Alamat</label>
                    <input type="text" class="form-control" id="address" name="address"
                        value="{{ old('address', $customer->address) }}" required>
                </div>

                <div class="d-flex justify-content-end">
                    <a href="{{ route('customers.index') }}" class="btn btn-secondary me-2">Batal</a>
                    <button type="submit" class="btn btn-primary">Update</button>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection
