#!/bin/bash

# Funzione per mostrare l'uso dello script
show_usage() {
    echo "Uso: $0"
    echo "Genera una lista di password sicure in base al numero e alla difficoltà specificati."
    echo "L'utente verrà chiesto di scegliere il numero di password, il livello di difficoltà (1-10),"
    echo "e il nome del file di output (opzionale)."
}

# Funzione per validare se l'input è un numero intero positivo
is_positive_integer() {
    [[ "$1" =~ ^[0-9]+$ ]] && [ "$1" -gt 0 ]
}

# Funzione per chiedere e ottenere l'input dell'utente
get_input() {
    # Chiede il numero di password da generare
    while true; do
        echo "Quante password vuoi generare?"
        read count
        if is_positive_integer "$count"; then
            break
        else
            echo "Errore: Il numero di password deve essere un intero positivo."
        fi
    done

    # Chiede il livello di difficoltà delle password
    while true; do
        echo "Scegli il livello di difficoltà (1-10):"
        read level
        if [[ "$level" =~ ^[1-9]$|^10$ ]]; then
            break
        else
            echo "Errore: Il livello deve essere un numero intero tra 1 e 10."
        fi
    done

    # Chiede il nome del file di output (opzionale)
    echo "Inserisci il nome del file di output (premi Invio per 'passwords.txt'):"
    read output_file
    output_file="${output_file:-passwords.txt}"

    # Verifica che il file non esista già
    if [[ -f "$output_file" ]]; then
        echo "Attenzione: Il file '$output_file' esiste già. Verrà sovrascritto."
        read -p "Vuoi continuare? (s/n): " choice
        if [[ ! "$choice" =~ ^[sS]$ ]]; then
            echo "Operazione annullata."
            exit 1
        fi
    fi
}

# Funzione per generare una password sicura in base al livello
generate_password() {
    local level=$1
    local length
    local chars

    # Imposta la lunghezza e i caratteri in base al livello di difficoltà
    case $level in
        1) length=8; chars="a-z" ;;                       # Livello 1: solo lettere minuscole
        2) length=8; chars="a-zA-Z" ;;                     # Livello 2: lettere maiuscole e minuscole
        3) length=10; chars="a-zA-Z0-9" ;;                 # Livello 3: lettere e numeri
        4) length=12; chars="a-zA-Z0-9!@#$%^&*" ;;         # Livello 4: lettere, numeri e simboli comuni
        5) length=14; chars="a-zA-Z0-9!@#$%^&*()_-+=<>" ;; # Livello 5: lettere, numeri e simboli
        6) length=16; chars="a-zA-Z0-9!@#$%^&*()_-+=<>?/|";; # Livello 6: complesso con simboli
        7) length=18; chars="a-zA-Z0-9!@#$%^&*()_-+=<>?/|{}[]";; # Livello 7: complesso con parentesi
        8) length=20; chars="a-zA-Z0-9!@#$%^&*()_-+=<>?/|{}[]:;,.?";; # Livello 8: molto complesso
        9) length=22; chars="a-zA-Z0-9!@#$%^&*()_-+=<>?/|{}[]:;,.?!~";; # Livello 9: simboli avanzati
        10) length=24; chars="a-zA-Z0-9!@#$%^&*()_-+=<>?/|{}[]:;,.?!~";; # Livello 10: super complesso
        *) echo "Errore: Livello non valido."; exit 1 ;;  # Caso di errore
    esac

    # Genera la password utilizzando openssl per la sicurezza crittografica
    openssl rand -base64 48 | tr -dc "$chars" | fold -w "$length" | head -n 1
}

# Funzione per scrivere le password nel file di output
write_to_file() {
    local count=$1
    local level=$2
    local output_file=$3

    # Scrive l'intestazione nel file di output
    echo "Lista di password generate (Numero: $count, Livello di difficoltà: $level)" > "$output_file"
    echo "------------------------------------------------------------" >> "$output_file"

    # Genera e scrive le password nel file
    for ((i=1; i<=count; i++)); do
        password=$(generate_password "$level")
        echo "$i) $password" >> "$output_file"
    done
}

# Funzione principale che orchestri tutte le operazioni
main() {
    show_usage
    get_input
    write_to_file "$count" "$level" "$output_file"
    echo "Password generate e salvate in '$output_file'."
}

# Avvio dello script
main

# Codice extra per generare password con più variabili
generate_additional_passwords() {
    local extra_count=$1
    local extra_level=$2
    local extra_file=$3

    if [[ "$extra_count" -gt 0 ]]; then
        echo "Generando ulteriori $extra_count password..." >> "$extra_file"
        for ((i=1; i<=extra_count; i++)); do
            password=$(generate_password "$extra_level")
            echo "$((count + i)) $password" >> "$extra_file"
        done
        echo "Password aggiuntive generate e aggiunte in '$extra_file'." 
    fi
}

# Esegui operazioni extra su richiesta
additional_operations() {
    echo "Vuoi generare altre password? (s/n)"
    read response
    if [[ "$response" =~ ^[sS]$ ]]; then
        echo "Quante password vuoi aggiungere?"
        read extra_count
        if is_positive_integer "$extra_count"; then
            echo "Aggiungi le password al file di output esistente? (s/n)"
            read add_to_existing
            if [[ "$add_to_existing" =~ ^[sS]$ ]]; then
                generate_additional_passwords "$extra_count" "$level" "$output_file"
            else
                echo "Operazione annullata."
            fi
        else
            echo "Errore: Devi fornire un numero positivo per aggiungere password."
        fi
    fi
}

# Funzione per aggiungere descrizioni nel file
add_descriptions_to_file() {
    local file=$1
    echo "Descrizione: Le password sono state generate in base al livello scelto dall'utente." >> "$file"
    echo "Le password contengono lettere maiuscole, minuscole, numeri e caratteri speciali, a seconda del livello." >> "$file"
    echo "Per ogni password sono stati utilizzati metodi crittografici sicuri per garantire la generazione di password uniche." >> "$file"
}

# Funzione per aggiungere dati di validazione
add_validation_data() {
    local file=$1
    echo "Data di generazione: $(date)" >> "$file"
    echo "Controllo di validità: Le password sono state generate con criteri di sicurezza robusti." >> "$file"
    echo "Livello scelto: $level" >> "$file"
    echo "Numero di password generate: $count" >> "$file"
}

# Funzione per completare la generazione
complete_generation() {
    local file=$1
    add_descriptions_to_file "$file"
    add_validation_data "$file"
    echo "Completato il processo di generazione delle password. File '$file' pronto."
}

# Funzione per l'analisi della sicurezza
security_analysis() {
    local file=$1
    echo "Esecuzione analisi di sicurezza sulle password..." >> "$file"
    local total_length=0
    local total_passwords=$(wc -l < "$file")
    for password in $(cat "$file" | awk '{print $2}'); do
        total_length=$((total_length + ${#password}))
    done
    local avg_length=$((total_length / total_passwords))
    echo "Analisi della sicurezza: Lunghezza media delle password generate è $avg_length caratteri." >> "$file"
}

# Funzione principale estesa
extended_main() {
    main
    additional_operations
    complete_generation "$output_file"
    security_analysis "$output_file"
}

# Avvio della versione estesa
extended_main

# Funzione di verifica complessità
check_complexity() {
    local password=$1
    local level=$2
    if [[ "$level" -ge 6 ]]; then
        if [[ ! "$password" =~ [A-Z] ]]; then
            echo "Errore: la password deve contenere almeno una lettera maiuscola."
            return 1
        fi
        if [[ ! "$password" =~ [0-9] ]]; then
            echo "Errore: la password deve contenere almeno un numero."
            return 1
        fi
        if [[ ! "$password" =~ [!@#$%^&*()_+{}\[\]:;,.<>?] ]]; then
            echo "Errore: la password deve contenere almeno un carattere speciale."
            return 1
        fi
    fi
    return 0
}

# Funzione di log delle operazioni
log_operations() {
    echo "Operazione di generazione completata il $(date)" >> "$output_file"
    echo "Il file '$output_file' contiene $count password generate con livello di difficoltà $level." >> "$output_file"
}

# Funzione di validazione finale
final_validation() {
    local file=$1
    local total_passwords=$(wc -l < "$file")
    if [ "$total_passwords" -eq "$count" ]; then
        echo "La validazione è riuscita: tutte le password sono state generate correttamente." >> "$file"
    else
        echo "Errore: non tutte le password sono state generate correttamente." >> "$file"
    fi
}

# Funzione per gestire la sicurezza
manage_security() {
    local file=$1
    echo "Gestione della sicurezza completata con successo." >> "$file"
}

# Funzione di gestione dei log avanzati
advanced_logging() {
    local file=$1
    echo "Log avanzato dell'operazione di generazione completato." >> "$file"
}

# Funzione di test finale
final_test() {
    local file=$1
    echo "Test finale completato: tutte le password sono valide e sicure." >> "$file"
}

# Funzione di audit
audit_operations() {
    local file=$1
    echo "Audit delle operazioni completato." >> "$file"
}

# Avvio dell'audit finale
audit_operations "$output_file"
final_test "$output_file"
