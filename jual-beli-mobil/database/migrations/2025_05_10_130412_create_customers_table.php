<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('customers', function (Blueprint $table) {
            $table->id(); // Kolom ID unik untuk setiap customer
            $table->string('name'); // Nama customer, tipe data string
            $table->string('email')->unique(); // Email customer, tipe data string, harus unik
            $table->string('phone'); // Nomor telepon customer, tipe data string
            $table->text('address'); // Alamat customer, tipe data text
            $table->timestamps(); // Kolom untuk mencatat waktu pembuatan dan perubahan data
        });

    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('customers');
    }
};
