# Rema 1000 Handleassistent 🛒

En Flutter applikasjon som hjelper brukere med å planlegge og navigere handleturer i Rema 1000-butikker.

## ✨ Funksjoner

### 🗺️ Butikknavigasjon

- Interaktive butikkkart
- Visuell representasjon av ganger og produktplasseringer
- Optimalisert rutefinning for effektive handleturer
- Støtte for flere butikklokasjoner

### 📝 Handleliste-håndtering

- Opprett og administrer flere handlelister
- Følg handlefremgang med visuelle indikatorer
- Kryss av varer mens du handler
- Antallstyring for hver vare
- Allergenvarsler

### 🤖 AI-assistent

- Opprett handlelister med naturlig språk

### 👤 Profil og innstillinger

- Håndtering av allergenpreferanser
- Håndtering av antall husholdningsmedlemmer

## 🏗️ Arkitektur

Dette prosjektet følger prinsipper for ren arkitektur med:

- **BLoC-mønster**: Tilstandshåndtering med flutter_bloc
- **Repository-mønster**: Abstraksjon av datatilgang
- **Dependency Injection**: MultiRepositoryProvider for avhengighetshåndtering
- **Modulær struktur**: Funksjonsbasert organisering

### Prosjektstruktur

```
lib/
├── constants/         # Appvide konstanter (tema, ressurser)
├── data/
│   ├── api/           # API-klient og nettverkslag
│   ├── models/        # Datamodeller
│   └── repositories/  # Repository-implementasjoner
├── map/               # Kartfunksjon (rutefinning, rendering)
├── page/              # UI-skjermer
│   ├── home/
│   ├── map/
│   ├── profile/
│   ├── shopping_lists/
│   ├── shopping_trip/
│   └── ai_assistant/
└── router/            # Appnavigasjon og ruting
```

## 🚀 Kom i gang

### Forutsetninger

- Flutter SDK
- Dart SDK
- Android Studio / Xcode (for mobilutvikling)
- En kjørende instans av Rema 1000 API-backend (se `backend/README.md`)

### Installasjon

1. **Klon repository**

   ```bash
   git clone <repository-url>
   cd start-code-2025/rema_1001
   ```

2. **Installer avhengigheter**

   ```bash
   flutter pub get
   ```

3. **Konfigurer miljøvariabler**

   Kopier eksempel-miljøfilen:

   ```bash
   cp .env.example .env
   ```

   Rediger `.env` og sett din API-vert:

   ```env
   API_HOST=http://localhost:3000
   ```

   > **Merk**: API_HOST kan være en full URL (f.eks. `http://localhost:3000`) eller bare vert og port (f.eks. `localhost:3000`). Default er `localhost:3000`

4. **Kjør appen**
   ```bash
   flutter run
   ```

## 🔧 Konfigurasjon

### Miljøvariabler

Appen bruker `flutter_dotenv` for å håndtere miljøspesifikk konfigurasjon. Opprett en `.env`-fil i rotmappen:

```env
API_HOST=http://localhost:3000
```

### API-konfigurasjon

Appen kommuniserer med et backend-API for:

- Butikkdata og kart
- Produktinformasjon
- Handleliste-håndtering
- AI-assistentfunksjonalitet

Sørg for at backend-APIet ditt kjører og er tilgjengelig på den konfigurerte `API_HOST`.

## 📦 Avhengigheter

### Hovedavhengigheter

- **flutter_bloc** - Tilstandshåndtering
- **go_router** - Navigasjon og ruting
- **http** - HTTP-klient for API-kall
- **flutter_dotenv** - Håndtering av miljøvariabler
- **skeletonizer** - Lastetilstand-UI
- **shared_preferences** - Lokal lagring
- **equatable** - Verdilikhet
- **carousel_slider** - Bildekaruseller
- **flutter_animate** - Animasjoner

## 🏗️ Bygging

### Android

```bash
flutter build apk
# eller for release
flutter build apk --release
```

### iOS

```bash
flutter build ios
# eller for release
flutter build ios --release
```

## 📱 Plattformstøtte

- ✅ Android
- ✅ iOS
- 🚧 Web
- 🚧 macOS
