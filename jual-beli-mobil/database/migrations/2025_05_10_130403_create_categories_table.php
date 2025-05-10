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
        Schema::create('categories', function (Blueprint $table) {
            $table->id(); // Kolom ID unik untuk setiap kategori
            $table->string('name'); // Nama kategori, tipe data string
            $table->text('description')->nullable(); // Deskripsi kategori, opsional, tipe data text
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
        Schema::dropIfExists('categories');
    }
};
