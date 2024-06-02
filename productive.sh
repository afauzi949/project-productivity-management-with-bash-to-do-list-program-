#!/bin/bash

# Direktori data
DATA_DIR="$HOME/Documents/productivity_data"
mkdir -p "$DATA_DIR"

# Fungsi untuk membaca JSON
baca_json() {
    cat "$1" | jq -r '.'
}

# Fungsi untuk menulis JSON
tulis_json() {
    echo "$2" | jq '.' > "$1"
}

# Fungsi menu utama (CLI)
function menu_utama() {
    clear 
    printf "\n╔═════════════════════════════╗\n"
    printf "║ %-27s ║\n" "  Pengelola Produktivitas"
    printf "╠═════════════════════════════╣\n"
    printf "║ %-27s ║\n" "1. Daftar Tugas"
    printf "║ %-27s ║\n" "2. Jadwal Pelajaran/Kuliah"
    printf "║ %-27s ║\n" "3. Pelacak Kebiasaan"
    printf "║ %-27s ║\n" "4. Pelacak Waktu"
    printf "╟─────────────────────────────╢\n" 
    printf "║ %-27s ║\n" "5. Keuangan"
    printf "║ %-27s ║\n" "6. Goals"
    printf "║ %-27s ║\n" "7. Layanan Darurat"
    printf "║ %-27s ║\n" "8. Daftar Bacaan"
    printf "║ %-27s ║\n" "9. Wishlist"
    printf "╟─────────────────────────────╢\n" 
    printf "║ %-27s ║\n" "0. Keluar"
    printf "╚═════════════════════════════╝\n"
    read -p "Pilihan: " pilihan
}


# Fungsi untuk daftar tugas (CLI)
function daftar_tugas() {
    tugas_file="$DATA_DIR/tugas.json"
    tugas=$(baca_json "$tugas_file")

    while true; do
        clear
        echo "Daftar Tugas:"
        echo "$tugas" | jq -r '.[] | "==========================\nMata Kuliah: \(.mata_kuliah)\nJenis Tugas: \(.jenis_tugas)\nTenggat Waktu: \(.deadline)\nStatus: \(.status)\nCatatan: \(.catatan)\n"'
        
        echo ""
        echo "╔═══════════════════════════════════╗"
        echo "║                                   ║"
        echo "║      <: Mau ngapain nih ??? :>    ║"
        echo "║                                   ║"
        printf "║ %-33s ║\n" "1. Tambah Tugas Baru  "
        printf "║ %-33s ║\n" "2. Edit Tugas  "
        printf "║ %-33s ║\n" "3. Tandai Tugas Sedang Dikerjakan"
        printf "║ %-33s ║\n" "4. Tandai Tugas Selesai   "  
        printf "║ %-33s ║\n" "5. Hapus Tugas"  
        printf "║ %-33s ║\n" "0. Kembali  "  
        echo "║                                   ║"
        echo "╚═══════════════════════════════════╝"
        read -p "Pilihan: " opsi

        case $opsi in
            1) # Tambah Tugas Baru
                read -p "Mata Kuliah: " mata_kuliah
                read -p "Jenis Tugas: " jenis_tugas
                read -p "Tenggat Waktu (YYYY-MM-DD): " deadline
                read -p "Catatan (opsional): " catatan
                tugas_baru='{"mata_kuliah": "'"$mata_kuliah"'", "jenis_tugas": "'"$jenis_tugas"'", "deadline": "'"$deadline"'", "status": "belum selesai", "catatan": "'"$catatan"'"}'
                tugas=$(echo "$tugas" | jq ". += [$tugas_baru]")
                tulis_json "$tugas_file" "$tugas"
                ;;
            2) # Edit Tugas
                echo "$tugas" | jq -r '.[] | "\(.mata_kuliah) - \(.jenis_tugas) (\(.deadline)) - \(.status)"' | nl -n ln 
                read -p "Pilih nomor tugas yang akan diedit: " index
                index=$((index - 1)) 
                if [[ $index =~ ^[0-9]+$ ]] && [ $index -lt $(echo "$tugas" | jq '. | length') ]; then
                    read -p "Mata Kuliah baru: " mata_kuliah_baru
                    read -p "Jenis Tugas baru: " jenis_tugas_baru
                    read -p "Tenggat Waktu baru (YYYY-MM-DD): " deadline_baru
                    read -p "Catatan baru (opsional): " catatan_baru
                    tugas=$(echo "$tugas" | jq ".[$index].mata_kuliah = \"$mata_kuliah_baru\" | .[$index].jenis_tugas = \"$jenis_tugas_baru\" | .[$index].deadline = \"$deadline_baru\" | .[$index].catatan = \"$catatan_baru\"")
                    tulis_json "$tugas_file" "$tugas"
                else
                    echo "Nomor tugas tidak valid"
                fi
                ;;
            3) # Tandai Tugas Sedang Dikerjakan
                echo "$tugas" | jq -r '.[] | "\(.mata_kuliah) - \(.jenis_tugas) (\(.deadline)) - \(.status)"' | nl -n ln
                read -p "Pilih nomor tugas yang akan ditandai sedang dikerjakan: " index
                index=$((index - 1)) 
                if [[ $index =~ ^[0-9]+$ ]] && [ $index -lt $(echo "$tugas" | jq '. | length') ]; then
                    tugas=$(echo "$tugas" | jq ".[$index].status = \"sedang dikerjakan\"")
                    tulis_json "$tugas_file" "$tugas"
                else
                    echo "Nomor tugas tidak valid"
                fi
                ;;
            4) # Tandai Tugas Selesai
                echo "$tugas" | jq -r '.[] | "\(.mata_kuliah) - \(.jenis_tugas) (\(.deadline)) - \(.status)"' | nl -n ln
                read -p "Pilih nomor tugas yang akan ditandai selesai: " index
                index=$((index - 1)) 
                if [[ $index =~ ^[0-9]+$ ]] && [ $index -lt $(echo "$tugas" | jq '. | length') ]; then
                    tugas=$(echo "$tugas" | jq ".[$index].status = \"selesai\"")
                    tulis_json "$tugas_file" "$tugas"
                else
                    echo "Nomor tugas tidak valid"
                fi
                ;;
            5) # Hapus Tugas
                echo "$tugas" | jq -r '.[] | "\(.mata_kuliah) - \(.jenis_tugas) (\(.deadline)) - \(.status)"' | nl -n ln
                read -p "Pilih nomor tugas yang akan dihapus: " index
                index=$((index - 1)) 
                if [[ $index =~ ^[0-9]+$ ]] && [ $index -lt $(echo "$tugas" | jq '. | length') ]; then
                    tugas=$(echo "$tugas" | jq "del(.[$index])")
                    tulis_json "$tugas_file" "$tugas"
                else
                    echo "Nomor tugas tidak valid"
                fi
                ;;
            0) # Kembali
                break
                ;;
            *) # Pilihan Tidak Valid
                echo "Pilihan tidak valid."
                ;;
        esac
    done
}

# Fungsi untuk menampilkan jadwal kuliah
function jadwal_kuliah() {
    JADWAL_FILE="$DATA_DIR/jadwal_kuliah.json"
    # Cek apakah file jadwal_kuliah.json ada, jika tidak buat file kosong
    if [ ! -f "$JADWAL_FILE" ]; then
        echo "[]" > "$JADWAL_FILE"
    fi

    # Fungsi untuk menampilkan jadwal kuliah
    function tampilkan_jadwal() {
        clear
        echo "╔══════════════════════════════════════════════════════════════════════════════════════╗"
        echo "║                                 Jadwal Kuliah (Semester 2)                           ║"
        echo "╚══════════════════════════════════════════════════════════════════════════════════════╝"

        # Mengurutkan jadwal berdasarkan hari
        jadwal_terurut=$(jq -s '.[0] | sort_by(.Hari, .Waktu)' < "$JADWAL_FILE")

        echo "$jadwal_terurut" | jq -r '.[] | "╔══════════════════════════════════════════════════════════════════════════════════════╗\n║ Kode: \(.Kode)\n║ Mata Kuliah: \(.["Mata Kuliah"])\n║ SKS: \(.SKS)\n║ Ke: \(.Ke)\n║ Pengajar: \(.Pengajar)\n║ Hari: \(.Hari)\n║ Waktu: \(.Waktu)\n║ Ruang: \(.Ruang)\n╚══════════════════════════════════════════════════════════════════════════════════════╝"'
        read -p "Tekan Enter untuk melanjutkan..."
    }

    # Fungsi untuk menambahkan jadwal kuliah
    function tambah_jadwal() {
        read -p "Masukkan Kode Mata Kuliah: " Kode
        read -p "Masukkan Nama Mata Kuliah: " Mata_Kuliah
        read -p "Masukkan Jumlah SKS: " SKS
        read -p "Masukkan Ke: " Ke
        read -p "Masukkan Pengajar: " Pengajar
        read -p "Masukkan Hari: " Hari
        read -p "Masukkan Waktu (HH:MM-HH:MM): " Waktu
        read -p "Masukkan Ruang: " Ruang

        # Mencari nomor terakhir untuk menentukan nomor jadwal berikutnya
        last_no=$(cat "$JADWAL_FILE" | jq '.[-1].No')
        if [ "$last_no" == "null" ]; then
            last_no=0
        fi
        No=$((last_no + 1))

        # Menambahkan jadwal baru ke file JSON
        jadwal_baru='{"No": '$No', "Kode": "'"$Kode"'", "Mata Kuliah": "'"$Mata_Kuliah"'", "SKS": '$SKS', "Ke": '$Ke', "Pengajar": "'"$Pengajar"'", "Hari": "'"$Hari"'", "Waktu": "'"$Waktu"'", "Ruang": "'"$Ruang"'"}'
        jq '. += ['"$jadwal_baru"']' "$JADWAL_FILE" > temp.json && mv temp.json "$JADWAL_FILE"
        echo "Jadwal berhasil ditambahkan."
        sleep 1
    }

    # Fungsi untuk menghapus jadwal kuliah
    function hapus_jadwal() {
        tampilkan_jadwal
        read -p "Masukkan nomor jadwal yang akan dihapus: " index
        index=$((index - 1)) # Konversi ke indeks 0
        # Validasi nomor jadwal
        if [[ $index =~ ^[0-9]+$ ]] && [ $index -lt $(cat "$JADWAL_FILE" | jq '. | length') ]; then
            # Menghapus jadwal berdasarkan nomor
            jq "del(.[$index])" "$JADWAL_FILE" > temp.json && mv temp.json "$JADWAL_FILE"
            echo "Jadwal berhasil dihapus."
            sleep 1
        else
            echo "Nomor jadwal tidak valid"
            sleep 1
        fi
    }

    # Menu utama
    while true; do
        clear

        echo ""
        echo "╔═════════════════════════════════════════╗"
        echo "║                                         ║"
        echo "║          <: Jadwal Kuliah :>            ║"
        echo "║                                         ║"
        printf "║ %-39s ║\n" "1. Tampilkan Jadwal Kuliah"
        printf "║ %-39s ║\n" "2. Tambah Jadwal Kuliah"
        printf "║ %-39s ║\n" "3. Hapus Jadwal Kuliah"
        printf "║ %-39s ║\n" "0. Kembali"
        echo "║                                         ║"
        echo "╚═════════════════════════════════════════╝"
        read -p "Pilihan: " opsi

        case $opsi in
            1) tampilkan_jadwal ;;
            2) tambah_jadwal ;;
            3) hapus_jadwal ;;
            0) break ;;
            *) echo "Pilihan tidak valid." ;;
        esac
    done
}

# Fungsi untuk pelacak kebiasaan (CLI)
function pelacak_kebiasaan() {
    kebiasaan_file="$DATA_DIR/kebiasaan.json"
    kebiasaan=$(baca_json "$kebiasaan_file")

    while true; do
        clear
        echo "╔════════════════════════════════════════╗"
        echo "║            Pelacak Kebiasaan           ║"
        echo "╚════════════════════════════════════════╝"
        echo ""
        echo "$kebiasaan" | jq -r '.[] | if .status == "selesai" then " " + .kebiasaan + " ✓" else .kebiasaan end' | nl -n ln
        echo ""
        echo "╔═══════════════════════════════════╗"
        echo "║                                   ║"
        echo "║   <: Mau ngapain nih ??? :>       ║"
        echo "║                                   ║"
        printf "║ %-33s ║\n" "1. Tambah Kebiasaan Baru"
        printf "║ %-33s ║\n" "2. Tandai Kebiasaan Selesai"
        printf "║ %-33s ║\n" "3. Reset Kebiasaan"
        printf "║ %-33s ║\n" "4. Hapus Daftar Kebiasaan"
        printf "║ %-33s ║\n" "0. Kembali"
        echo "║                                   ║"
        echo "╚═══════════════════════════════════╝"
        read -p "Pilihan: " opsi

        case $opsi in
            1) # Tambah Kebiasaan Baru
                read -p "Kebiasaan: " kebiasaan_baru
                kebiasaan_entry='{"kebiasaan": "'"$kebiasaan_baru"'", "status": "belum selesai"}'
                kebiasaan=$(echo "$kebiasaan" | jq ". += [$kebiasaan_entry]")
                tulis_json "$kebiasaan_file" "$kebiasaan"
                ;;
            2) # Tandai Kebiasaan Selesai
                echo "$kebiasaan" | jq -r '.[] | .kebiasaan' | nl -n ln
                read -p "Pilih nomor kebiasaan yang akan ditandai selesai: " index
                index=$((index - 1))
                if [[ $index =~ ^[0-9]+$ ]] && [ $index -lt $(echo "$kebiasaan" | jq '. | length') ]; then
                    kebiasaan=$(echo "$kebiasaan" | jq ".[$index].status = \"selesai\"")
                    tulis_json "$kebiasaan_file" "$kebiasaan"
                else
                    echo "Nomor kebiasaan tidak valid"
                fi
                ;;
            3) # Reset Kebiasaan
                kebiasaan=$(echo "$kebiasaan" | jq 'map(.status = "belum selesai")')
                tulis_json "$kebiasaan_file" "$kebiasaan"
                ;;
            4) # Hapus Daftar Kebiasaan
                echo "Apakah Anda ingin menghapus:"
                echo "1. Semua daftar kebiasaan"
                echo "2. Salah satu daftar kebiasaan"
                read -p "Pilihan: " delete_option

                case $delete_option in
                    1)
                        read -p "Apakah Anda yakin ingin menghapus semua daftar kebiasaan? (y/n): " confirm
                        if [ "$confirm" == "y" ]; then
                            kebiasaan="[]"
                            tulis_json "$kebiasaan_file" "$kebiasaan"
                            echo "Daftar kebiasaan telah dihapus."
                        else
                            echo "Penghapusan daftar kebiasaan dibatalkan."
                        fi
                        ;;
                    2)
                        echo "$kebiasaan" | jq -r '.[] | .kebiasaan' | nl -n ln
                        read -p "Pilih nomor kebiasaan yang akan dihapus: " index
                        index=$((index - 1))
                        if [[ $index =~ ^[0-9]+$ ]] && [ $index -lt $(echo "$kebiasaan" | jq '. | length') ]; then
                            kebiasaan=$(echo "$kebiasaan" | jq "del(.[$index])")
                            tulis_json "$kebiasaan_file" "$kebiasaan"
                            echo "Daftar kebiasaan telah dihapus."
                        else
                            echo "Nomor kebiasaan tidak valid"
                        fi
                        ;;
                    *)
                        echo "Pilihan tidak valid."
                        ;;
                esac
                ;;
            0) # Kembali
                break
                ;;
            *) # Pilihan Tidak Valid
                echo "Pilihan tidak valid."
                ;;
        esac
        read -p "Tekan Enter untuk melanjutkan..."
    done
}

# Fungsi untuk pelacak waktu (CLI)
function pelacak_waktu() {
    waktu_file="$DATA_DIR/waktu.json"
    waktu=$(baca_json "$waktu_file")

    while true; do
        clear
        echo "Pelacak Waktu:"
        echo "$waktu" | jq -r '.[] | "==========================\nAktivitas: \(.aktivitas)\nDurasi: \(.durasi)\nCatatan: \(.catatan)\nTanggal: \(.tanggal)\nHari: \(.hari)"'

        echo ""
        echo "╔═══════════════════════════════════╗"
        echo "║                                   ║"
        echo "║   <: Mau ngapain nih ??? :>       ║"
        echo "║                                   ║"
        printf "║ %-33s ║\n" "1. Tambah Aktivitas"
        printf "║ %-33s ║\n" "2. Edit Aktivitas"
        printf "║ %-33s ║\n" "3. Hapus Aktivitas"
        printf "║ %-33s ║\n" "0. Kembali"
        echo "║                                   ║"
        echo "╚═══════════════════════════════════╝"
        read -p "Pilihan: " opsi

        case $opsi in
            1) # Tambah Waktu Aktivitas
                read -p "Aktivitas: " aktivitas
                read -p "Durasi (jam:menit): " durasi
                read -p "Catatan (opsional): " catatan
                read -p "Tanggal (YYYY-MM-DD): " tanggal
                read -p "Hari: " hari
                waktu_baru='{"aktivitas": "'"$aktivitas"'", "durasi": "'"$durasi"'", "catatan": "'"$catatan"'", "tanggal": "'"$tanggal"'", "hari": "'"$hari"'"}'
                waktu=$(echo "$waktu" | jq ". += [$waktu_baru]")
                tulis_json "$waktu_file" "$waktu"
                ;;
            2) # Edit Waktu Aktivitas
                echo "$waktu" | jq -r '.[] | "\(.aktivitas) - \(.durasi) (\(.catatan))"' | nl -n ln
                read -p "Pilih nomor aktivitas yang akan diedit: " index
                index=$((index - 1))
                if [[ $index =~ ^[0-9]+$ ]] && [ $index -lt $(echo "$waktu" | jq '. | length') ]; then
                    read -p "Aktivitas baru: " aktivitas_baru
                    read -p "Durasi baru (jam:menit): " durasi_baru
                    read -p "Catatan baru (opsional): " catatan_baru
                    read -p "Tanggal baru (YYYY-MM-DD): " tanggal_baru
                    read -p "Hari baru: " hari_baru
                    waktu=$(echo "$waktu" | jq ".[$index].aktivitas = \"$aktivitas_baru\" | .[$index].durasi = \"$durasi_baru\" | .[$index].catatan = \"$catatan_baru\" | .[$index].tanggal = \"$tanggal_baru\" | .[$index].hari = \"$hari_baru\"")
                    tulis_json "$waktu_file" "$waktu"
                else
                    echo "Nomor aktivitas tidak valid"
                fi
                ;;
            3) # Hapus Waktu Aktivitas
                echo "$waktu" | jq -r '.[] | "\(.aktivitas)"' | nl -n ln
                read -p "Pilih nomor aktivitas yang akan dihapus (masukkan 0 untuk menghapus semua): " index
                if [[ $index =~ ^[0-9]+$ ]] && [ $index -ge 0 ] && [ $index -le $(echo "$waktu" | jq '. | length') ]; then
                    if [ $index -eq 0 ]; then
                        read -p "Apakah Anda yakin ingin menghapus semua daftar waktu aktivitas? (y/n): " confirm
                        if [ "$confirm" == "y" ]; then
                            waktu="[]"
                            tulis_json "$waktu_file" "$waktu"
                            echo "Daftar waktu aktivitas telah dihapus."
                        else
                            echo "Penghapusan daftar waktu aktivitas dibatalkan."
                        fi
                    else
                        waktu=$(echo "$waktu" | jq "del(.[${index - 1}])")
                        tulis_json "$waktu_file" "$waktu"
                        echo "Waktu aktivitas telah dihapus."
                    fi
                else
                    echo "Nomor aktivitas tidak valid"
                fi
                ;;
            0) # Kembali
                break
                ;;
            *) # Pilihan Tidak Valid
                echo "Pilihan tidak valid."
                ;;
        esac
    done
}

# Fungsi untuk pelacak keuangan (CLI)
function pelacak_keuangan() {
    keuangan_file="$DATA_DIR/keuangan.json"
    keuangan=$(baca_json "$keuangan_file")

    while true; do
        clear
        echo "Pelacak Keuangan:"
        echo "$keuangan" | jq -r '.[] | "==========================\nTanggal: \(.tanggal)\nDeskripsi: \(.deskripsi)\nKategori: \(.kategori)\nJumlah: \(.jumlah)"'

        echo ""
        echo "╔═══════════════════════════════════╗"
        echo "║                                   ║"
        echo "║   <: Mau ngapain nih ??? :>       ║"
        echo "║                                   ║"
        printf "║ %-33s ║\n" "1. Tambah Transaksi"
        printf "║ %-33s ║\n" "2. Lihat Riwayat Transaksi"
        printf "║ %-33s ║\n" "3. Edit Transaksi"
        printf "║ %-33s ║\n" "4. Hapus Transaksi"
        printf "║ %-33s ║\n" "5. Laporan Keuangan"
        printf "║ %-33s ║\n" "6. Kelola Anggaran"
        printf "║ %-33s ║\n" "7. Kelola Tabungan"
        printf "║ %-33s ║\n" "0. Kembali"
        echo "║                                   ║"
        echo "╚═══════════════════════════════════╝"
        read -p "Pilihan: " opsi

        case $opsi in
            1) # Tambah Transaksi
                read -p "Tanggal (YYYY-MM-DD): " tanggal
                read -p "Deskripsi: " deskripsi
                read -p "Kategori: " kategori
                read -p "Jumlah: " jumlah
                transaksi_baru='{"tanggal": "'"$tanggal"'", "deskripsi": "'"$deskripsi"'", "kategori": "'"$kategori"'", "jumlah": '$jumlah'}'
                keuangan=$(echo "$keuangan" | jq ". += [$transaksi_baru]")
                tulis_json "$keuangan_file" "$keuangan"
                ;;
            2) # Lihat Riwayat Transaksi
                echo "$keuangan" | jq -r '.[] | "==========================\nTanggal: \(.tanggal)\nDeskripsi: \(.deskripsi)\nKategori: \(.kategori)\nJumlah: \(.jumlah)"' | less
                ;;
            3) # Edit Transaksi
                echo "$keuangan" | jq -r '.[] | "\(.tanggal) - \(.deskripsi) (\(.jumlah))"' | nl -n ln
                read -p "Pilih nomor transaksi yang akan diedit: " index
                index=$((index - 1))
                if [[ $index =~ ^[0-9]+$ ]] && [ $index -lt $(echo "$keuangan" | jq '. | length') ]; then
                    read -p "Tanggal baru (YYYY-MM-DD): " tanggal_baru
                    read -p "Deskripsi baru: " deskripsi_baru
                    read -p "Kategori baru: " kategori_baru
                    read -p "Jumlah baru: " jumlah_baru
                    keuangan=$(echo "$keuangan" | jq ".[$index].tanggal = \"$tanggal_baru\" | .[$index].deskripsi = \"$deskripsi_baru\" | .[$index].kategori = \"$kategori_baru\" | .[$index].jumlah = $jumlah_baru")
                    tulis_json "$keuangan_file" "$keuangan"
                else
                    echo "Nomor transaksi tidak valid"
                fi
                ;;
            4) # Hapus Transaksi
                echo "1. Hapus salah satu transaksi"
                echo "2. Hapus semua transaksi"
                read -p "Pilihan: " opsi_hapus
                if [ "$opsi_hapus" == "1" ]; then
                    echo "$keuangan" | jq -r '.[] | "\(.tanggal) - \(.deskripsi) (\(.jumlah))"' | nl -n ln
                    read -p "Pilih nomor transaksi yang akan dihapus: " index
                    index=$((index - 1))
                    if [[ $index =~ ^[0-9]+$ ]] && [ $index -lt $(echo "$keuangan" | jq '. | length') ]; then
                        keuangan=$(echo "$keuangan" | jq "del(.[${index}])")
                        tulis_json "$keuangan_file" "$keuangan"
                    else
                        echo "Nomor transaksi tidak valid"
                    fi
                elif [ "$opsi_hapus" == "2" ]; then
                    read -p "Apakah Anda yakin ingin menghapus semua transaksi? (y/n): " confirm
                    if [ "$confirm" == "y" ]; then
                        keuangan="[]"
                        tulis_json "$keuangan_file" "$keuangan"
                        echo "Semua transaksi telah dihapus."
                    else
                        echo "Penghapusan semua transaksi dibatalkan."
                    fi
                else
                    echo "Pilihan tidak valid."
                fi
                ;;
            5) # Laporan Keuangan
                total_pemasukan=$(echo "$keuangan" | jq '[.[] | select(.jumlah > 0) | .jumlah] | add')
                total_pengeluaran=$(echo "$keuangan" | jq '[.[] | select(.jumlah < 0) | .jumlah] | add')
                echo "Total Pemasukan: $total_pemasukan"
                echo "Total Pengeluaran: $total_pengeluaran"
                read -p "Tekan Enter untuk melanjutkan..."
                ;;
            6) # Kelola Anggaran
                # Fitur tambahan untuk mengelola anggaran
                ;;
            7) # Kelola Tabungan
                # Fitur tambahan untuk mengelola tabungan
                ;;
            0) # Kembali
                break
                ;;
            *) # Pilihan Tidak Valid
                echo "Pilihan tidak valid."
                ;;
        esac
        read -p "Tekan Enter untuk melanjutkan..."
    done
}

# Fungsi untuk keuangan (CLI)
function keuangan() {
    keuangan_file="$DATA_DIR/keuangan.json"
    saldo_file="$DATA_DIR/saldo.json"

    keuangan=$(baca_json "$keuangan_file")
    saldo=$(baca_json "$saldo_file")

    while true; do
        clear
        echo "Pelacak Keuangan:"
        echo "$keuangan" | jq -r '.[] | "==========================\nTanggal: \(.tanggal)\nKeterangan: \(.keterangan)\nKategori: \(.kategori)\nJumlah: \(.jumlah)\nTipe: \(.tipe)"'

        read -p "Tekan Enter untuk melanjutkan..."
        clear

        echo ""
        echo "╔═══════════════════════════════════╗"
        echo "║                                   ║"
        echo "║      <: Mau ngapain nih ??? :>    ║"
        echo "║                                   ║"
        printf "║ %-33s ║\n" "1. Tambah Pemasukan"
        printf "║ %-33s ║\n" "2. Tambah Pengeluaran"
        printf "║ %-33s ║\n" "3. Hapus Transaksi"
        printf "║ %-33s ║\n" "4. Tampilkan Jumlah Saldo"
        printf "║ %-33s ║\n" "5. Tampilkan Daftar Pengeluaran"
        printf "║ %-33s ║\n" "6. Reset Transaksi"
        printf "║ %-33s ║\n" "0. Kembali"
        echo "║                                   ║"
        echo "╚═══════════════════════════════════╝"
        read -p "Pilihan: " opsi

        case $opsi in
            1) # Tambah Pemasukan
                read -p "Tanggal (YYYY-MM-DD): " tanggal
                read -p "Keterangan: " keterangan
                read -p "Kategori: " kategori
                read -p "Jumlah: " jumlah
                tipe="pemasukan"
                transaksi_baru='{"tanggal": "'"$tanggal"'", "keterangan": "'"$keterangan"'", "kategori": "'"$kategori"'", "jumlah": '"$jumlah"', "tipe": "'"$tipe"'"}'
                keuangan=$(echo "$keuangan" | jq ". += [$transaksi_baru]")
                tulis_json "$keuangan_file" "$keuangan"
                saldo=$(echo "$saldo" | jq ".saldo += $jumlah")
                tulis_json "$saldo_file" "$saldo"
                ;;
            2) # Tambah Pengeluaran
                read -p "Tanggal (YYYY-MM-DD): " tanggal
                read -p "Keterangan: " keterangan
                read -p "Kategori: " kategori
                read -p "Jumlah: " jumlah
                tipe="pengeluaran"
                transaksi_baru='{"tanggal": "'"$tanggal"'", "keterangan": "'"$keterangan"'", "kategori": "'"$kategori"'", "jumlah": '"$jumlah"', "tipe": "'"$tipe"'"}'
                keuangan=$(echo "$keuangan" | jq ". += [$transaksi_baru]")
                tulis_json "$keuangan_file" "$keuangan"
                saldo=$(echo "$saldo" | jq ".saldo -= $jumlah")
                tulis_json "$saldo_file" "$saldo"
                ;;
            3) # Hapus Transaksi
                echo "$keuangan" | jq -r '.[] | "\(.tanggal) - \(.keterangan) - \(.kategori) - \(.jumlah) - \(.tipe)"' | nl -n ln
                read -p "Pilih nomor transaksi yang akan dihapus: " index
                index=$((index - 1))
                if [[ $index =~ ^[0-9]+$ ]] && [ $index -lt $(echo "$keuangan" | jq '. | length') ]; then
                    transaksi=$(echo "$keuangan" | jq ".[$index]")
                    tipe=$(echo "$transaksi" | jq -r '.tipe')
                    jumlah=$(echo "$transaksi" | jq -r '.jumlah')
                    if [ "$tipe" == "pemasukan" ]; then
                        saldo=$(echo "$saldo" | jq ".saldo -= $jumlah")
                    elif [ "$tipe" == "pengeluaran" ]; then
                        saldo=$(echo "$saldo" | jq ".saldo += $jumlah")
                    fi
                    keuangan=$(echo "$keuangan" | jq "del(.[$index])")
                    tulis_json "$keuangan_file" "$keuangan"
                    tulis_json "$saldo_file" "$saldo"
                else
                    echo "Nomor transaksi tidak valid"
                fi
                ;;
            4) # Tampilkan Jumlah Saldo
                echo "Saldo saat ini: Rp$(echo "$saldo" | jq -r '.saldo')"
                read -p "Tekan Enter untuk melanjutkan..."
                ;;
            5) # Tampilkan Daftar Pengeluaran
                echo "Daftar Pengeluaran:"
                echo "$keuangan" | jq -r '.[] | select(.tipe == "pengeluaran") | "==========================\nTanggal: \(.tanggal)\nKeterangan: \(.keterangan)\nKategori: \(.kategori)\nJumlah: \(.jumlah)"'
                read -p "Tekan Enter untuk melanjutkan..."
                ;;
            6) # Reset Transaksi
                read -p "Apakah Anda yakin ingin mereset semua transaksi? [y/N]: " confirm
                if [[ "$confirm" =~ ^[Yy]$ ]]; then
                    echo "[]" > "$keuangan_file"
                    echo '{"saldo": 0}' > "$saldo_file"
                    keuangan=$(baca_json "$keuangan_file")
                    saldo=$(baca_json "$saldo_file")
                    echo "Semua transaksi telah direset."
                    read -p "Tekan Enter untuk melanjutkan..."
                fi
                ;;
            0) # Kembali
                break
                ;;
            *) # Pilihan Tidak Valid
                echo "Pilihan tidak valid."
                ;;
        esac
    done
}

# Fungsi untuk goals (CLI)
function goals() {
    goals_file="$DATA_DIR/goals.json"

    # Cek apakah file goals.json ada, jika tidak buat file kosong
    if [ ! -f "$goals_file" ]; then
        echo "[]" > "$goals_file"
    fi

    goals=$(baca_json "$goals_file")

    while true; do
        clear

        echo ""
        echo "╔═══════════════════════════════════╗"
        echo "║                                   ║"
        echo "║       <: Mau ngapain nih ??? :>   ║"
        echo "║                                   ║"
        printf "║ %-33s ║\n" "1. Tambah Goals Baru"
        printf "║ %-33s ║\n" "2. Update Progress Goals"
        printf "║ %-33s ║\n" "3. Hapus Goals"
        printf "║ %-33s ║\n" "4. Tampilkan Daftar Goals"
        printf "║ %-33s ║\n" "0. Kembali"
        echo "║                                   ║"
        echo "╚═══════════════════════════════════╝"
        read -p "Pilihan: " opsi

        case $opsi in
            1) # Tambah Goal Baru
                read -p "Nama Goal: " nama
                read -p "Deskripsi Goal: " deskripsi
                read -p "Kategori: " kategori
                goal_baru='{"nama": "'"$nama"'", "deskripsi": "'"$deskripsi"'", "kategori": "'"$kategori"'", "tercapai": "belum tercapai"}'
                goals=$(echo "$goals" | jq ". += [$goal_baru]")
                tulis_json "$goals_file" "$goals"
                ;;
            2) # Update Progress Goal
                echo "$goals" | jq -r '.[] | "\(.nama) - \(.deskripsi) - \(.kategori) - Tercapai: \(.tercapai)"' | nl -n ln
                read -p "Pilih nomor goal yang akan diupdate: " index
                index=$((index - 1))
                if [[ $index =~ ^[0-9]+$ ]] && [ $index -lt $(echo "$goals" | jq '. | length') ]; then
                    goals=$(echo "$goals" | jq ".[$index].tercapai = \"tercapai ✓\"")
                    tulis_json "$goals_file" "$goals"
                else
                    echo "Nomor goal tidak valid"
                fi
                ;;
            3) # Hapus Goal
                clear
                echo ""
                echo "╔════════════════════════════════════════════╗"
                echo "║                                            ║"
                echo "║  Hapus Bagian Apa?                         ║"
                echo "║                                            ║"
                printf "║ %-42s ║\n" "1. Hapus Salah Satu Goal"
                printf "║ %-42s ║\n" "2. Hapus Semua Goals"
                echo "║                                            ║"
                echo "╚════════════════════════════════════════════╝"
                read -p "Pilihan: " hapus_opsi

                case $hapus_opsi in
                    1) # Hapus Satu Goal
                        echo "$goals" | jq -r '.[] | "\(.nama) - \(.deskripsi) - \(.kategori) - Tercapai: \(.tercapai)"' | nl -n ln
                        read -p "Pilih nomor goals yang akan dihapus: " index
                        index=$((index - 1))
                        if [[ $index =~ ^[0-9]+$ ]] && [ $index -lt $(echo "$goals" | jq '. | length') ]; then
                            goals=$(echo "$goals" | jq "del(.[$index])")
                            tulis_json "$goals_file" "$goals"
                        else
                            echo "Nomor goals tidak valid"
                        fi
                        ;;
                    2) # Hapus Semua Goals
                        echo "Anda yakin ingin menghapus semua goals? (y/n)"
                        read -n 1 -r
                        echo
                        if [[ $REPLY =~ ^[Yy]$ ]]; then
                            echo "[]" > "$goals_file"
                            goals="[]"
                            echo "Semua goals berhasil dihapus."
                            sleep 1
                        fi
                        ;;
                    *) # Pilihan Tidak Valid
                        echo "Pilihan tidak valid."
                        ;;
                esac
                ;;
            4) # Tampilkan Daftar Goals
                clear
                echo "Daftar Goals:"
                echo "$goals" | jq -r '.[] | "==========================\nNama: \(.nama)\nDeskripsi: \(.deskripsi)\nKategori: \(.kategori)\nTercapai: \(.tercapai) \(if .tercapai == "tercapai" then "✓" else "" end)"'
                read -p "Tekan Enter untuk melanjutkan..."
                ;;
            0) # Kembali
                break
                ;;
            *) # Pilihan Tidak Valid
                echo "Pilihan tidak valid."
                ;;
        esac
    done
}

# Fungsi untuk wishlist (CLI)
function wishlist() {
    wishlist_file="$DATA_DIR/wishlist.json"

    # Cek apakah file wishlist.json ada, jika tidak buat file kosong
    if [ ! -f "$wishlist_file" ]; then
        echo "[]" > "$wishlist_file"
    fi

    wishlist=$(baca_json "$wishlist_file")

    while true; do
        clear

        echo ""
        echo "╔═══════════════════════════════════╗"
        echo "║                                   ║"
        echo "║       <: Mau ngapain nih ??? :>   ║"
        echo "║                                   ║"
        printf "║ %-33s ║\n" "1. Tambah Wishlist Baru"
        printf "║ %-33s ║\n" "2. Update Progress Wishlist"
        printf "║ %-33s ║\n" "3. Hapus Wishlist"
        printf "║ %-33s ║\n" "4. Tampilkan Daftar Wishlist"
        printf "║ %-33s ║\n" "0. Kembali"
        echo "║                                   ║"
        echo "╚═══════════════════════════════════╝"
        read -p "Pilihan: " opsi

        case $opsi in
            1) # Tambah Wishlist Baru
                read -p "Nama Wishlist: " nama
                read -p "Deskripsi Wishlist: " deskripsi
                read -p "Kategori: " kategori
                read -p "Jumlah Target: " jumlah_target
                read -p "Tanggal Target (YYYY-MM-DD): " tanggal_target
                wishlist_baru='{"nama": "'"$nama"'", "deskripsi": "'"$deskripsi"'", "kategori": "'"$kategori"'", "jumlah_target": '"$jumlah_target"', "jumlah_saat_ini": 0, "tanggal_target": "'"$tanggal_target"'", "tercapai": "belum tercapai"}'
                wishlist=$(echo "$wishlist" | jq ". += [$wishlist_baru]")
                tulis_json "$wishlist_file" "$wishlist"
                ;;
            2) # Update Progress Wishlist
                echo "$wishlist" | jq -r '.[] | "\(.nama) - \(.deskripsi) - \(.kategori) - Jumlah Target: \(.jumlah_target) - Jumlah Saat Ini: \(.jumlah_saat_ini) - Tanggal Target: \(.tanggal_target) - Tercapai: \(.tercapai)"' | nl -n ln
                read -p "Pilih nomor wishlist yang akan diupdate: " index
                index=$((index - 1))
                if [[ $index =~ ^[0-9]+$ ]] && [ $index -lt $(echo "$wishlist" | jq '. | length') ]; then
                    read -p "Jumlah yang ingin ditambahkan: " jumlah_tambah
                    wishlist=$(echo "$wishlist" | jq ".[$index].jumlah_saat_ini += $jumlah_tambah")
                    jumlah_saat_ini=$(echo "$wishlist" | jq ".[$index].jumlah_saat_ini")
                    jumlah_target=$(echo "$wishlist" | jq ".[$index].jumlah_target")
            
                    # Menghapus tanda kutip dari variabel jumlah_saat_ini dan jumlah_target
                    jumlah_saat_ini=$(echo "$jumlah_saat_ini" | tr -d '"')
                    jumlah_target=$(echo "$jumlah_target" | tr -d '"')
            
                    if (( jumlah_saat_ini >= jumlah_target )); then
                        wishlist=$(echo "$wishlist" | jq ".[$index].tercapai = \"tercapai ✓\"")
                    fi
                    tulis_json "$wishlist_file" "$wishlist"
                else
                    echo "Nomor wishlist tidak valid"
                fi
                ;;
            3) # Hapus Wishlist
                clear
                echo ""
                echo "╔════════════════════════════════════════════╗"
                echo "║                                            ║"
                echo "║  Hapus Bagian Apa?                         ║"
                echo "║                                            ║"
                printf "║ %-42s ║\n" "1. Hapus Salah Satu Wishlist"
                printf "║ %-42s ║\n" "2. Hapus Semua Wishlist"
                echo "║                                            ║"
                echo "╚════════════════════════════════════════════╝"
                read -p "Pilihan: " hapus_opsi

                case $hapus_opsi in
                    1) # Hapus Satu Wishlist
                        echo "Daftar Wishlist:"
                        echo "$wishlist" | jq -r 'to_entries | .[] | "\(.key + 1). ==========================\nNama: \(.value.nama)\nDeskripsi: \(.value.deskripsi)\nKategori: \(.value.kategori)\nJumlah Target: \(.value.jumlah_target)\nJumlah Saat Ini: \(.value.jumlah_saat_ini)\nTanggal Target: \(.value.tanggal_target)\nTercapai: \(.value.tercapai)\n"'
                        read -p "Pilih nomor wishlist yang akan dihapus: " index
                        index=$((index - 1))
                        if [[ $index =~ ^[0-9]+$ ]] && [ $index -lt $(echo "$wishlist" | jq '. | length') ]; then
                            wishlist=$(echo "$wishlist" | jq "del(.[$index])")
                            tulis_json "$wishlist_file" "$wishlist"
                        else
                            echo "Nomor wishlist tidak valid"
                        fi
                        ;;
                    2) # Hapus Semua Wishlist
                        echo "Anda yakin ingin menghapus semua wishlist? (y/n)"
                        read -n 1 -r
                        echo
                        if [[ $REPLY =~ ^[Yy]$ ]]; then
                            echo "[]" > "$wishlist_file"
                            wishlist="[]"
                            echo "Semua wishlist berhasil dihapus."
                            sleep 1
                        fi
                        ;;
                    *) # Pilihan Tidak Valid
                        echo "Pilihan tidak valid."
                        ;;
                esac
                ;;

            4) # Tampilkan Daftar Wishlist
                clear
                echo "Daftar Wishlist:"
                echo "$wishlist" | jq -r '.[] | "==========================\nNama: \(.nama)\nDeskripsi: \(.deskripsi)\nKategori: \(.kategori)\nJumlah Target: \(.jumlah_target)\nJumlah Saat Ini: \(.jumlah_saat_ini)\nTanggal Target: \(.tanggal_target)\nTercapai: \(.tercapai)"'
                read -p "Tekan Enter untuk melanjutkan..."
                ;;
            0) # Kembali
                break
                ;;
            *) # Pilihan Tidak Valid
                echo "Pilihan tidak valid."
                ;;
        esac
    done
}

# Fungsi untuk daftar bacaan (CLI)
function daftar_bacaan() {
    bacaan_file="$DATA_DIR/daftar_bacaan.json"

    # Cek apakah file daftar_bacaan.json ada, jika tidak buat file kosong
    if [ ! -f "$bacaan_file" ]; then
        echo "[]" > "$bacaan_file"
    fi

    bacaan=$(baca_json "$bacaan_file")

    while true; do
        clear

        echo ""
        echo "╔═══════════════════════════════════╗"
        echo "║                                   ║"
        echo "║       <: Daftar Bacaan :>         ║"
        echo "║                                   ║"
        printf "║ %-33s ║\n" "1. Tambah Bacaan Baru"
        printf "║ %-33s ║\n" "2. Hapus Bacaan"
        printf "║ %-33s ║\n" "3. Tampilkan Daftar Bacaan"
        printf "║ %-33s ║\n" "0. Kembali"
        echo "║                                   ║"
        echo "╚═══════════════════════════════════╝"
        read -p "Pilihan: " opsi

        case $opsi in
            1) # Tambah Bacaan Baru
                read -p "Kategori (jurnal/catatan biasa/catatan penting/artikel): " kategori
                read -p "Judul: " judul
                read -p "Deskripsi: " deskripsi
                read -p "Tanggal (YYYY-MM-DD): " tanggal
                bacaan_baru='{"kategori": "'"$kategori"'", "judul": "'"$judul"'", "deskripsi": "'"$deskripsi"'", "tanggal": "'"$tanggal"'"}'
                bacaan=$(echo "$bacaan" | jq ". += [$bacaan_baru]")
                tulis_json "$bacaan_file" "$bacaan"
                ;;
            2) # Hapus Bacaan
                clear
                echo ""
                echo "╔════════════════════════════════════════════╗"
                echo "║                                            ║"
                echo "║  Hapus Bacaan                              ║"
                echo "║                                            ║"
                printf "║ %-42s ║\n" "1. Hapus Salah Satu Bacaan"
                printf "║ %-42s ║\n" "2. Hapus Semua Bacaan"
                echo "║                                            ║"
                echo "╚════════════════════════════════════════════╝"
                read -p "Pilihan: " hapus_opsi

                case $hapus_opsi in
                    1) # Hapus Satu Bacaan
                        echo "Daftar Bacaan:"
                        echo "$bacaan" | jq -r 'to_entries | .[] | "\(.key + 1). ==========================\nKategori: \(.value.kategori)\nJudul: \(.value.judul)\nDeskripsi: \(.value.deskripsi)\nTanggal: \(.value.tanggal)"'
                        read -p "Pilih nomor bacaan yang akan dihapus: " index
                        index=$((index - 1))
                        if [[ $index =~ ^[0-9]+$ ]] && [ $index -lt $(echo "$bacaan" | jq '. | length') ]; then
                            bacaan=$(echo "$bacaan" | jq "del(.[$index])")
                            tulis_json "$bacaan_file" "$bacaan"
                        else
                            echo "Nomor bacaan tidak valid"
                        fi
                        ;;
                    2) # Hapus Semua Bacaan
                        echo "Anda yakin ingin menghapus semua bacaan? (y/n)"
                        read -n 1 -r
                        echo
                        if [[ $REPLY =~ ^[Yy]$ ]]; then
                            echo "[]" > "$bacaan_file"
                            bacaan="[]"
                            echo "Semua bacaan berhasil dihapus."
                            sleep 1
                        fi
                        ;;
                    *) # Pilihan Tidak Valid
                        echo "Pilihan tidak valid."
                        ;;
                esac
                ;;
            3) # Tampilkan Daftar Bacaan
                clear
                echo "Daftar Bacaan:"
                echo "$bacaan" | jq -r '.[] | "==========================\nKategori: \(.kategori)\nJudul: \(.judul)\nDeskripsi: \(.deskripsi)\nTanggal: \(.tanggal)"'
                read -p "Tekan Enter untuk melanjutkan..."
                ;;
            0) # Kembali
                break
                ;;
            *) # Pilihan Tidak Valid
                echo "Pilihan tidak valid."
                ;;
        esac
    done
}

# Fungsi untuk layanan darurat (CLI)
function layanan_darurat() {
    layanan_file="$DATA_DIR/layanan_darurat.json"

    # Cek apakah file layanan_darurat.json ada, jika tidak buat file kosong
    if [ ! -f "$layanan_file" ]; then
        echo "[]" > "$layanan_file"
    fi

    layanan=$(baca_json "$layanan_file")

    while true; do
        clear
        echo ""
        echo "╔════════════════════════════════════════════╗"
        echo "║                                            ║"
        echo "║          Daftar Layanan Darurat            ║"
        echo "║                                            ║"
        printf "║ %-42s ║\n" "1. Tampilkan Kumpulan Kontak"
        printf "║ %-42s ║\n" "2. Tambah Kontak Layanan"
        printf "║ %-42s ║\n" "3. Hapus Kontak Layanan"
        printf "║ %-42s ║\n" "0. Kembali"
        echo "║                                            ║"
        echo "╚════════════════════════════════════════════╝"
        read -p "Pilihan: " opsi

        case $opsi in
            1) # Tampilkan Kumpulan Kontak
                clear
                echo "Daftar Kontak Layanan Darurat:"
                echo "$layanan" | jq -r '.[] | "==========================\nNama: \(.nama)\nKontak: \(.kontak)\nDeskripsi: \(.deskripsi)"'
                read -p "Tekan Enter untuk melanjutkan..."
                ;;
            2) # Tambah Kontak Layanan
                read -p "Nama Layanan: " nama
                read -p "Kontak: " kontak
                read -p "Deskripsi: " deskripsi
                layanan_baru='{"nama": "'"$nama"'", "kontak": "'"$kontak"'", "deskripsi": "'"$deskripsi"'"}'
                layanan=$(echo "$layanan" | jq ". += [$layanan_baru]")
                tulis_json "$layanan_file" "$layanan"
                ;;
            3) # Hapus Kontak Layanan
                clear
                echo "Daftar Kontak Layanan Darurat:"
                echo "$layanan" | jq -r '.[] | "==========================\nNama: \(.nama)\nKontak: \(.kontak)\nDeskripsi: \(.deskripsi)"' | nl -n ln
                read -p "Pilih nomor layanan yang akan dihapus: " index
                index=$((index - 1))
                if [[ $index =~ ^[0-9]+$ ]] && [ $index -lt $(echo "$layanan" | jq '. | length') ]; then
                    layanan=$(echo "$layanan" | jq "del(.[$index])")
                    tulis_json "$layanan_file" "$layanan"
                else
                    echo "Nomor layanan tidak valid"
                fi
                ;;
            0) # Kembali
                break
                ;;
            *) # Pilihan Tidak Valid
                echo "Pilihan tidak valid."
                ;;
        esac
    done
}

# Loop utama program
while true; do
    menu_utama
    case $pilihan in
        1) daftar_tugas ;;
        2) jadwal_kuliah ;;
        3) pelacak_kebiasaan ;;
        4) pelacak_waktu ;;
        5) keuangan ;;
        6) goals ;;
        7) layanan_darurat ;;
        8) daftar_bacaan ;;
        9) wishlist ;;
        0) exit 0 ;;
    esac
done
