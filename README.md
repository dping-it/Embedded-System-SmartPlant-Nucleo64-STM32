**Corso di Laurea Magistrale in Ingegneria Informatica – progetto Embedded** **System**
#


















**Project Work : Soluzione Bare Metal** 

**per la gestione di in un sistema “pianta”.**
# **
# Sommario
[	1](#_Toc95566912)

[**Descrizione del progetto**	4](#_Toc95566913)

[**Prerequisiti concettuali**	4](#_Toc95566914)

[**Componenti Hardware**	4](#_Toc95566915)

[**Schema del sistema**	5](#_Toc95566916)

[**Schema di collegamento Header**	5](#_Toc95566917)

[**Il targhet: RaspBerry PI 4 B**	6](#_Toc95566918)

[**Componenti Software**	6](#_Toc95566919)

[**Preparazione dell’ambiente di sviluppo**	6](#_Toc95566920)

[**Preparazione della SD e dell’interprete**	7](#_Toc95566921)

[**Descrizione dei componenti**	9](#_Toc95566922)

[***FTDI 232-USB Interfaccia UART***	9](#_Toc95566923)

[***Modulo LCD 1602 con Drive I^2C PCF85741/3***	9](#_Toc95566924)

[**Tastierino KeyPad a matrice 5x4**	12](#_Toc95566925)

[**Modulo relay HL-52s**	13](#_Toc95566926)

[**Sistema LED**	14](#_Toc95566927)

[**Flusso degli eventi**	15](#_Toc95566928)

[**Il codice**	15](#_Toc95566929)

[**Dettaglio files sorgenti**	15](#_Toc95566930)

[**Testing**	35](#_Toc95566931)

[**Conclusioni**	40](#_Toc95566932)




**
## **Descrizione del progetto**
Realizzazione di una interfaccia di controllo per la gestione del clima ottimale in un sistema “serra”. Ovviamente il progetto è realizzato su dimensioni ridotte, ma è comunque riproducibile su larga scala con i dovuti accorgimenti. Il sistema è realizzato con il **target scelto “NUCLEO60 SMT32**”, consente di gestire in maniera automatizzata il controllo della ventilazione e dell’irraggiamento luminoso alle colture presenti nella serra. Una volta impostati i parametri di temporizzazione da tastiera il sistema “bare metal” gestisce l’azione degli attuatori riportando a display le relative informazioni, in maniera del tutto autonoma, come vedremo nel dettaglio più avanti. 

## **Prerequisiti concettuali**
Per lo sviluppo di un progetto di questa tipologia si utilizza un approccio bottom up. Il target va scelto in funzione alle aspettative del sistema: scegliere una CPU General Purpose piuttosto che una CPU Embedded e viceversa è una scelta che deve tenere conto di tanti aspetti: la possibilità di interazione con i sensori del sistema, l’utilizzo di hardware specializzato, le caratteristiche relative al tempo medio nei confronti delle istruzioni necessarie al funzionamento, il fattore economico costo *componenti – effetto ottenuto*, e, non da poco, l’aspetto del consumo energetico che oggi giorno è preponderante. Per la realizzazione di un Software embedded possiamo scegliere tra tre tipologie di programmazione:

- Compilazione su una macchina target che richiede il supporto di un OS per l’utilizzo dei toolchain.
- La compilazione incrociata “Cross-compilation” che prevede l’uso di una macchina di sviluppo collegata al target o ad un emulatore con l’ausilio di software di supporto.
- Programmazione interattiva sul target: il codice sorgente viene inviato direttamente all’interprete (*PIJForthOS* nel nostro caso) che lo compila nello stesso target.

Inoltre risulta essere molto utile testare i meccanismi e le connessioni dei i sensori con un linguaggio ad alto livello, se disponibile, prima di cimentarsi allo sviluppo di codice specializzato a basso livello. 
## **Componenti Hardware**
Per la realizzazione del progetto è necessario il seguente materiale:

- NUCLEO64;

- Sharp TC1602B-01 VER:00 16x2 LCD BLU;
- Philips PCF8574AT Remote 8-bit I/O espansione per I2C-bus;
- Relay Module HL-52s;
- Lampada piatta Led 10 W 220v con interruttore;
- Ventola 12V  15\*15 cm;

- BreadBoard e Cavi connessione M/F e M/M;
- 3 Led vari colori;
- 3 Resistori ceramidi da 200 ohm;
- Personal Computer;
- Cavo USB – miniUSB M/M;
- Vaso, terra, piante e rivestimento pellicola.

## **Schema del sistema**

## **Schema di collegamento Header**