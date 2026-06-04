# UX/UI — AIP Gest (Fase 4)

> **Principio rector**: Un préstamo en menos de 15 segundos.
> **Perfiles**: Encargado AIP (gestión total) · Practicante (operador rápido)
> **Plataformas**: Mobile-first · Desktop/web adaptable

---

## 1. Objetivo de velocidad

| Acción | Tiempo máximo | Pantallas |
|---|---|---|
| Crear préstamo (practicante experto) | 10-12 seg | 2-3 |
| Crear préstamo (practicante nuevo) | 20-25 seg | 3 |
| Registrar devolución | 8-10 seg | 2 |
| Buscar equipo | 3-5 seg | 1 |
| Firmar digitalmente | 4-6 seg | 1 |

**Optimizaciones clave**:
- Docentes y equipos se cachean al iniciar sesión (sin loading en cada paso)
- Autocompletado con 2 caracteres + fuzzy match
- Botones grandes (mínimo 48dp) para uso sin leer
- Defaults inteligentes: fecha = hoy, hora = ahora, encargado = usuario actual
- Confirmación visual inmediata (check + microanimación 200ms)

---

## 2. Arquitectura de navegación

### 2.1 Mobile (BottomNavigation)

```
┌──────────────────────────────────────┐
│            StatusBar                 │
├──────────────────────────────────────┤
│  [≡ Menú]     Título    [🔍] [✚]    │ ← AppBar contextual
├──────────────────────────────────────┤
│                                      │
│         CONTENIDO PRINCIPAL          │
│         (cambia por tab)             │
│                                      │
│                                      │
├──────────────────────────────────────┤
│  📊    📋    🔧    👨‍🏫    📜       │ ← BottomNav (5 tabs)
│ Dashboard  Prést.  Equip.  Doc.  Hist.│
└──────────────────────────────────────┘
```

**BottomNavigation tabs**:

| Ícono | Label | Rol primario |
|---|---|---|
| 📊 | Dashboard | Resumen, accesos rápidos |
| 📋 | Préstamos | Crear préstamo, activos |
| 🔧 | Equipos | Inventario, estados |
| 👨‍🏫 | Docentes | CRUD docentes |
| 📜 | Historial | Búsqueda y filtros |

**FloatingActionButton**: aparece en tabs relevantes
- Tab Préstamos → ✚ Nuevo préstamo
- Tab Equipos → ✚ Nuevo equipo
- Tab Docentes → ✚ Nuevo docente

### 2.2 Desktop/Web (Sidebar + TopBar)

```
┌─────────────┬────────────────────────────────────┐
│             │  AIP Gest         [🔍]  👤 Carlos  │ ← TopBar
│  📊 Dash    ├────────────────────────────────────┤
│  📋 Pres    │                                    │
│  🔧 Equip   │                                    │
│  👨‍🏫 Doc     │        CONTENIDO PRINCIPAL        │
│  📜 Hist    │                                    │
│             │                                    │
│  ⚙️ Config  │                                    │
│  🚪 Salir   │                                    │
│             │                                    │
└─────────────┴────────────────────────────────────┘
   Sidebar                      Content
```

---

## 3. Dashboard principal

```
┌──────────────────────────────────────┐
│  📊 Dashboard                09:41   │
├──────────────────────────────────────┤
│                                      │
│  ┌──────┐ ┌──────┐ ┌──────┐         │
│  │  📋  │ │  🔧  │ │  ⚠️  │         │ ← 3 metric cards
│  │  12  │ │  8   │ │  3   │         │
│  │Activos│ │Disp. │ │Mant. │         │
│  └──────┘ └──────┘ └──────┘         │
│                                      │
│  Préstamos activos hoy              │ ← Section header
│  ┌──────────────────────────────┐   │
│  │ Lucía Fernández   09:15 📋   │   │ ← tap → detalle
│  │ 3 equipos · Carlos entregó   │   │
│  ├──────────────────────────────┤   │
│  │ Ricardo Gutiérrez 08:00 📋   │   │
│  │ 2 equipos · Carlos entregó   │   │
│  ├──────────────────────────────┤   │
│  │ Ver todos →                  │   │ ← tap → lista completa
│  └──────────────────────────────┘   │
│                                      │
│  ⚡ Acción rápida                    │
│  ┌──────────────────────────────┐   │
│  │  ✚ NUEVO PRÉSTAMO           │   │ ← Botón grande #1
│  └──────────────────────────────┘   │
│  ┌──────────────────────────────┐   │
│  │  ↩ REGISTRAR DEVOLUCIÓN     │   │ ← Botón grande #2
│  └──────────────────────────────┘   │
│                                      │
└──────────────────────────────────────┘
```

**Métricas del dashboard**:

| Card | Dato | Color | Acción tap |
|---|---|---|---|
| Préstamos activos | Conteo + "Activos" | Azul | Ir a lista préstamos activos |
| Equipos disponibles | Conteo + "Disponibles" | Verde | Ir a equipos filtrado |
| En mantenimiento | Conteo + "Mantenimiento" | Naranja | Ir a equipos filtrado |

---

## 4. Flujo completo de préstamo (< 15 seg)

### 4.1 Diagrama de pantallas

```
 ┌──────────┐
 │ DASHBOARD│
 │ o TAB    │
 │ PRÉSTAMOS│
 └────┬─────┘
      │ tap "Nuevo préstamo" (FAB o botón)
      ▼
 ┌──────────────┐     ┌──────────────────┐
 │   Paso 1:    │     │   Paso 2:        │
 │ SELECCIONAR  │────►│ SELECCIONAR      │
 │ DOCENTE      │     │ EQUIPOS          │
 │              │     │                  │
 │ [Buscar...]  │     │ [Buscar equipo]  │
 │              │     │                  │
 │ ► Lucía F.  │     │ ☑ Laptop Dell 001│
 │ ► Ricardo G.│     │ ☑ Laptop HP  002 │
 │ ► Hugo S.   │     │ ☐ Cargador Dell  │
 │ ► Mónica V. │     │ ☐ Extensión   001│
 │              │     │                  │
 │ (lista filtra │     │ (multi-select)   │
 │  en tiempo    │     │                  │
 │  real)        │     │                  │
 └──────┬───────┘     └────────┬─────────┘
        │                      │
        │                      │
        ▼                      ▼
 ┌──────────────────────────────────────┐
 │         Paso 3: FIRMAR               │
 │                                      │
 │  Docente: Lucía Fernández           │
 │  Equipos: HP ProBook, Cargador, Ext │
 │  Entregó: Carlos Mendoza            │
 │  Fecha:   28/05/2026 09:15          │
 │                                      │
 │  ┌──────────────────────────────┐   │
 │  │                              │   │
 │  │      [FIRMA AQUÍ]            │   │
 │  │                              │   │
 │  └──────────────────────────────┘   │
 │                                      │
 │  ┌──────────────┐ ┌──────────────┐  │
 │  │  ← ATRÁS    │ │  ✅ CONFIRMAR │  │
 │  └──────────────┘ └──────────────┘  │
 │                                      │
 └──────────────────────────────────────┘
        │ tap CONFIRMAR
        ▼
 ┌──────────────────────────────────────┐
 │         🎉 PRÉSTAMO CREADO           │
 │                                      │
 │   ✅ Lucía Fernández                 │
 │      3 equipos · 09:15               │
 │                                      │
 │  ┌──────────────────────────────┐   │
 │  │  📋 VER DETALLE             │   │
 │  ├──────────────────────────────┤   │
 │  │  🏠 VOLVER AL INICIO       │   │
 │  └──────────────────────────────┘   │
 │                                      │
 └──────────────────────────────────────┘
```

### 4.2 Desglose de tiempo por paso

| Paso | Acción | Tiempo | UX trick |
|---|---|---|---|
| 1 | Escribir 2-3 letras del docente | 2-3 seg | Autocomplete + fuzzy, keyboard auto-abre |
| 2 | Tap docente en lista | 1 seg | Resultados grandes, fácil de tocar |
| 3 | Tap equipos (multi-select) | 3-5 seg | Check grandes, preselected si es "préstamo típico" |
| 4 | Tap FIRMAR | 1 seg | Botón primario grande |
| 5 | Dibujar firma | 3-4 seg | Canvas con preview, botón "Rehacer" |
| 6 | Tap CONFIRMAR | 1 seg | Feedback háptico inmediato |
| **Total** | | **11-15 seg** | |

### 4.3 Pantalla crear préstamo — wireframe detallado

```
 Mobile                            Desktop
┌──────────────────────┐    ┌──────────────────────────────┐
│ ← Nuevo préstamo     │    │ ✚ Nuevo préstamo     👤 C.M.│
├──────────────────────┤    ├──────────────────────────────┤
│                      │    │  Docente                     │
│ Docente              │    │ ┌──────────────────────────┐ │
│ ┌──────────────────┐ │    │ │ Buscar docente...    🔍  │ │
│ │ Buscar docente 🔍│ │    │ └──────────────────────────┘ │
│ └──────────────────┘ │    │ ┌──────────────────────────┐ │
│                      │    │ │ 📌 Lucía Fernández    ✓  │ │
│ ► Lucía Fernández    │    │ │   · Comunicación         │ │
│   · Comunicación     │    │ ├──────────────────────────┤ │
│ ► Ricardo Gutiérrez  │    │ │ 📌 Ricardo Gutiérrez     │ │
│   · Matemáticas      │    │ │   · Matemáticas          │ │
│ ► Hugo Sánchez       │    │ └──────────────────────────┘ │
│   · Ciencias         │    │                              │
│                      │    │  Equipos (selecciona 1+)     │
│  ─── 3 seleccionados│    │ ┌──────┐ ┌──────┐ ┌──────┐  │
│                      │    │ │      │ │      │ │      │  │
│  ✅ Continuar →      │    │ │ Dell │ │  HP  │ │Cargad│  │
│                      │    │ │  002 │ │  005 │ │  001 │  │
│                      │    │ └──────┘ └──────┘ └──────┘  │
│                      │    │ ┌──────┐ ┌──────┐           │
│                      │    │ │ Ext. │ │Cam.  │           │
│                      │    │ │  001 │ │  001 │           │
│                      │    │ └──────┘ └──────┘           │
│                      │    │                              │
│                      │    │  [← Atrás]   ✅ Continuar    │
└──────────────────────┘    └──────────────────────────────┘
```

---

## 5. Flujo completo de devolución (< 10 seg)

### 5.1 Diagrama

```
 ┌──────────┐
 │ CUALQUIER│
 │ PANTALLA │
 └────┬─────┘
      │ tap "Registrar devolución"
      ▼
 ┌──────────────────────────────────────┐
 │  ↩ REGISTRAR DEVOLUCIÓN             │
 │                                      │
 │  Selecciona el préstamo a devolver:  │
 │                                      │
 │  ┌──────────────────────────────┐   │
 │  │ Lucía Fernández    09:15 📋  │   │ ← grande, fácil de tap
 │  │ HP ProBook · Cargador · Ext  │   │   Badge naranja "3"
 │  ├──────────────────────────────┤   │
 │  │ Ricardo Gutiérrez  08:00 📋  │   │
 │  │ Dell Latitude · Cargador     │   │   Badge naranja "2"
 │  └──────────────────────────────┘   │
 │                                      │
 └──────────────────────────────────────┘
      │ tap en un préstamo
      ▼
 ┌──────────────────────────────────────┐
 │  ↩ Devolver: Lucía Fernández        │
 │                                      │
 │  ¿Qué equipos se devuelven?          │
 │                                      │
 │  ☑ HP ProBook 450 G9   [✅ Bueno]  │ ← check + estado
 │  ☑ Cargador HP 65W      [✅ Bueno] │
 │  ☑ Extensión REG-6T     [✅ Bueno] │
 │                                      │
 │  Observaciones (opcional):           │
 │  ┌──────────────────────────────┐   │
 │  │ Todo en buen estado          │   │
 │  └──────────────────────────────┘   │
 │                                      │
 │  CONTINUAR →                        │
 └──────────────────────────────────────┘
      │ tap CONTINUAR
      ▼
 ┌──────────────────────────────────────┐
 │  FIRMA DE DEVOLUCIÓN                │
 │                                      │
 │  Recibe: María Ríos (practicante)    │
 │  Entrega: Lucía Fernández (docente)  │
 │                                      │
 │  ┌──────────────────────────────┐   │
 │  │         FIRMA AQUÍ           │   │
 │  │                              │   │
 │  └──────────────────────────────┘   │
 │                                      │
 │  ┌──────────────┐ ┌──────────────┐  │
 │  │  ← ATRÁS    │ │ ✅ CONFIRMAR  │  │
 │  └──────────────┘ └──────────────┘  │
 │                                      │
 └──────────────────────────────────────┘
      │ tap CONFIRMAR
      ▼
 ┌──────────────────────────────────────┐
 │        ✅ DEVOLUCIÓN REGISTRADA      │
 │                                      │
 │  🎉 3 equipos devueltos             │
 │  Lucía Fernández · 14:50            │
 │                                      │
 │  ┌──────────────────────────────┐   │
 │  │  🏠 VOLVER AL INICIO       │   │
 │  └──────────────────────────────┘   │
 └──────────────────────────────────────┘
```

### 5.2 Optimización para velocidad

| Técnica | Beneficio |
|---|---|
| Precargar lista de préstamos activos | 0 espera al abrir pantalla |
| Equipos pre-checkeados por defecto | Un tap si es devolución total |
| Botón "Devolver todo" | Devuelve todo en 1 tap |
| Comentarios rápidos predefinidos | "Buen estado", "Con detalles", etc. |

---

## 6. Pantalla de equipos

```
┌──────────────────────────────────────┐
│  🔧 Equipos                🔍 ✚    │
├──────────────────────────────────────┤
│                                      │
│  [Todos ▼] [Disponible] [Prestado]   │ ← Filtros tipo chip
│  [Mantenimiento] [Dado de baja]      │
│                                      │
│  ┌──────────────────────────────┐   │
│  │ Buscar por código o nombre 🔍│   │ ← Search bar
│  └──────────────────────────────┘   │
│                                      │
│  ┌──────────────────────────────┐   │
│  │ AIP-LDELL-001               │   │
│  │ Dell Latitude 3420          │   │
│  │ 🟢 Disponible               │   │
│  ├──────────────────────────────┤   │
│  │ AIP-LHP-002                 │   │
│  │ HP ProBook 450 G9           │   │
│  │ 🔵 Prestado (Lucía F.)      │   │ ← muestra quien lo tiene
│  ├──────────────────────────────┤   │
│  │ AIP-CARG-001                │   │
│  │ Cargador Dell 65W           │   │
│  │ 🟡 Mantenimiento            │   │
│  ├──────────────────────────────┤   │
│  │ AIP-LHP-003                 │   │
│  │ HP Pavilion x360            │   │
│  │ ⚫ Dado de baja             │   │
│  └──────────────────────────────┘   │
│                                      │
└──────────────────────────────────────┘

--- Detalle de equipo (tap) ---
┌──────────────────────────────────────┐
│ ← AIP-LDELL-001            ✏️ 🗑    │
├──────────────────────────────────────┤
│                                      │
│  Tipo:      Laptop Dell              │
│  Modelo:    Latitude 3420            │
│  Marca:     Dell                     │
│  Serie:     SN-DELL-001              │
│  Estado:    🟢 Disponible            │
│                                      │
│  ─── Historial de préstamos ───     │
│  28/05  → Lucía Fernández    📋     │
│  22/05  → Mónica Velasco     📋 ✅  │
│  15/05  → Hugo Sánchez       📋 ✅  │
│                                      │
└──────────────────────────────────────┘
```

---

## 7. Pantalla de docentes

```
┌──────────────────────────────────────┐
│  👨‍🏫 Docentes               🔍 ✚    │
├──────────────────────────────────────┤
│                                      │
│  ┌──────────────────────────────┐   │
│  │ Buscar docente...        🔍  │   │
│  └──────────────────────────────┘   │
│                                      │
│  ┌──────────────────────────────┐   │
│  │ Dr. Ricardo Gutiérrez       │   │
│  │ Matemáticas · 987654321     │   │
│  │ 🟢 Activo                   │   │
│  ├──────────────────────────────┤   │
│  │ Mg. Lucía Fernández         │   │
│  │ Comunicación · 987654322    │   │
│  │ 🟢 Activo                   │   │
│  ├──────────────────────────────┤   │
│  │ Prof. Silvia Pinedo         │   │
│  │ Arte                         │   │
│  │ 🔴 Inactivo                 │   │
│  └──────────────────────────────┘   │
│                                      │
└──────────────────────────────────────┘
```

---

## 8. Pantalla de historial

```
┌──────────────────────────────────────┐
│  📜 Historial                      │
├──────────────────────────────────────┤
│                                      │
│  [Hoy] [Esta semana] [Este mes] [▼] │ ← Rango de fechas
│                                      │
│  ┌──────────────────────────────┐   │
│  │ 28/05 09:15  📋  PRÉSTAMO   │   │
│  │ Lucía Fernández             │   │
│  │ Carlos Mendoza entregó      │   │
│  │ 🟡 Activo                   │   │
│  ├──────────────────────────────┤   │
│  │ 26/05 14:50  ↩  DEVOLUCIÓN  │   │
│  │ Hugo Sánchez                │   │
│  │ María Ríos recibió          │   │
│  │ ✅ 2 equipos devueltos      │   │
│  ├──────────────────────────────┤   │
│  │ 26/05 10:00  📋  PRÉSTAMO   │   │
│  │ Hugo Sánchez                │   │
│  │ Carlos Mendoza entregó      │   │
│  │ ✅ Devuelto                 │   │
│  └──────────────────────────────┘   │
│                                      │
│  [Cargar más...]                     │ ← Paginación infinita
│                                      │
└──────────────────────────────────────┘

--- Filtros avanzados ---
┌──────────────────────────────────────┐
│  Filtrar historial                  │
│                                      │
│  📅 Desde:  [01/05/2026 ▾]          │
│  📅 Hasta:  [31/05/2026 ▾]          │
│  👨‍🏫 Docente: [Buscar... ▾]        │
│  📋 Tipo:    [Todos   ▾]            │
│  🔧 Equipo:  [Buscar... ▾]          │
│                                      │
│  APLICAR FILTROS                     │
└──────────────────────────────────────┘
```

---

## 9. Captura de firma digital

### 9.1 Componente SignaturePad

```
┌──────────────────────────────────────┐
│  Firma digital                       │
│                                      │
│  Docente: Lucía Fernández           │
│                                      │
│  ┌──────────────────────────────┐   │
│  │                              │   │
│  │   ┌──┐  ┌──┐                │   │
│  │   │  │  │  │                │   │
│  │   │  │  │  │  ┌──┐          │   │
│  │   └──┘  │  │  │  │          │   │
│  │          └──┘  └──┘          │   │
│  │                              │   │
│  │     FIRMA AQUÍ               │   │
│  └──────────────────────────────┘   │
│                                      │
│  🔄 Rehacer  ⚫ Grosor  🎨 Color   │ ← Toolbar minimal
│                                      │
│  Cancelar            Confirmar firma │
└──────────────────────────────────────┘
```

### 9.2 UX de firma

| Estado | Comportamiento |
|---|---|
| Lienzo vacío | Texto fantasma "Firma aquí" centrado |
| Dibujando | Trazo suave (bezier), feedback visual inmediato |
| Pausa > 2 seg | Auto-detección de firma completa (opcional) |
| Error | Botón "Rehacer" — limpia lienzo |
| Confirmada | Preview en miniatura + microcheck ✅ |

### 9.3 Almacenamiento

```
1. Usuario firma en SignaturePad (canvas)
2. Al confirmar → exportar a PNG (480x200, fondo transparente)
3. Upload a Supabase Storage /firmas/{contexto}/{id}/{rol}_{timestamp}.png
4. Guardar metadata en tabla firmas_digitales
5. Mostrar preview en detalle del préstamo
```

---

## 10. Wireframes ASCII — Pantallas clave

### 10.1 Login

```
┌──────────────────────────────────────┐
│                                      │
│                                      │
│           🏫 AIP Gest               │ ← Logo institucional
│      Control de Préstamos            │
│                                      │
│                                      │
│  ┌──────────────────────────────┐   │
│  │  usuario@iep.edu.pe         │   │
│  └──────────────────────────────┘   │
│                                      │
│  ┌──────────────────────────────┐   │
│  │  ********                   │   │
│  └──────────────────────────────┘   │
│                                      │
│  ┌──────────────────────────────┐   │
│  │      INICIAR SESIÓN         │   │ ← Botón primario
│  └──────────────────────────────┘   │
│                                      │
│  ¿Olvidaste tu contraseña?          │
│                                      │
│                                      │
└──────────────────────────────────────┘
```

### 10.2 Lista de préstamos activos

```
┌──────────────────────────────────────┐
│  📋 Préstamos activos       🔍 ✚   │
├──────────────────────────────────────┤
│                                      │
│  ┌──────────────────────────────┐   │
│  │ 🔵 Lucía Fernández          │   │
│  │    3 equipos · hace 4h       │   │
│  │    Entregó: Carlos M.        │   │
│  │                        ⏳ 09:15│
│  ├──────────────────────────────┤   │
│  │ 🔵 Ricardo Gutiérrez        │   │
│  │    2 equipos · hace 5h       │   │
│  │    Entregó: Carlos M.        │   │
│  │                        ⏳ 08:00│
│  └──────────────────────────────┘   │
│                                      │
│  [Ver todos los préstamos →]        │
│                                      │
└──────────────────────────────────────┘
```

### 10.3 Detalle de préstamo

```
┌──────────────────────────────────────┐
│ ← Préstamo                  ↩ Devol │
├──────────────────────────────────────┤
│                                      │
│  👨‍🏫 Docente: Lucía Fernández       │
│  👤 Entregó:  Carlos Mendoza        │
│  📅 Inicio:   28/05/2026 09:15      │
│  📅 Est. fin: 28/05/2026 16:00      │
│  🔵 Estado:   Activo                │
│                                      │
│  ─── Equipos (3) ───               │
│  ┌──────────────────────────────┐   │
│  │ ✅ HP ProBook 450 G9        │   │
│  │ ✅ Cargador HP 65W           │   │
│  │ ✅ Extensión REG-6T          │   │
│  └──────────────────────────────┘   │
│                                      │
│  ─── Firmas ───                     │
│  📝 Encargado: [ver firma ▸]       │
│  📝 Docente:   [ver firma ▸]       │
│                                      │
│  [↩ REGISTRAR DEVOLUCIÓN]          │ ← Botón grande
│                                      │
└──────────────────────────────────────┘
```

### 10.4 Confirmación rápida (post-préstamo)

```
┌──────────────────────────────────────┐
│                                      │
│                                      │
│              ✅                       │
│                                      │
│      ¡Préstamo registrado!          │
│                                      │
│    Lucía Fernández                   │
│    3 equipos                         │
│    Carlos Mendoza · 09:15           │
│                                      │
│                                      │
│  ┌──────────────────────────────┐   │
│  │      NUEVO PRÉSTAMO        │   │ ← Siguiente acción rápida
│  └──────────────────────────────┘   │
│                                      │
│  ┌──────────────────────────────┐   │
│  │      VOLVER AL INICIO      │   │
│  └──────────────────────────────┘   │
│                                      │
│                                      │
└──────────────────────────────────────┘
```

### 10.5 Empty states

```
┌──────────────────────────────────────┐
│  📋 Préstamos activos       🔍 ✚   │
├──────────────────────────────────────┤
│                                      │
│                                      │
│            📭                        │
│                                      │
│     No hay préstamos activos        │
│                                      │
│     Todos los equipos están          │
│     disponibles.                     │
│                                      │
│  ┌──────────────────────────────┐   │
│  │  ✚ CREAR PRIMER PRÉSTAMO   │   │ ← CTA principal
│  └──────────────────────────────┘   │
│                                      │
│                                      │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│  🔧 Equipos                 🔍 ✚   │
├──────────────────────────────────────┤
│                                      │
│  [Todos ▼] filtros...               │
│                                      │
│            📦                        │
│                                      │
│     No hay equipos registrados       │
│                                      │
│  ┌──────────────────────────────┐   │
│  │  ✚ REGISTRAR PRIMER EQUIPO  │   │
│  └──────────────────────────────┘   │
│                                      │
└──────────────────────────────────────┘
```

### 10.6 Loading states

```
┌──────────────────────────────────────┐
│  📋 Préstamos activos               │
├──────────────────────────────────────┤
│                                      │
│       ◌ ◌ ◌                         │ ← Skeleton loader
│  ┌──────────────────────────────┐   │
│  │ ████████████ ████████        │   │
│  │ ████████ ██████████████       │   │
│  │ ██████ ████████████           │   │
│  ├──────────────────────────────┤   │
│  │ ████████████ ████████        │   │
│  │ ████████ ██████████████       │   │
│  │ ██████ ████████████           │   │
│  └──────────────────────────────┘   │
│                                      │
│       Cargando préstamos...         │
│                                      │
└──────────────────────────────────────┘
```

### 10.7 Error states

```
┌──────────────────────────────────────┐
│  📋 Préstamos activos               │
├──────────────────────────────────────┤
│                                      │
│            ⚠️                        │
│                                      │
│     No se pudieron cargar los        │
│     préstamos.                       │
│                                      │
│     🔴 Error de conexión            │
│                                      │
│  ┌──────────────────────────────┐   │
│  │      REINTENTAR             │   │
│  └──────────────────────────────┘   │
│                                      │
└──────────────────────────────────────┘
```

---

## 11. Micro-interacciones y retroalimentación

### 11.1 Tiempos de feedback

| Acción | Feedback visual | Feedback táctil | Duración |
|---|---|---|---|
| Tap botón | Ripple + escala 0.95 | Háptico (HapticFeedback.mediumImpact) | 100ms |
| Préstamo creado | Check + confeti sutil | Háptico fuerte | 400ms |
| Error | Shake horizontal + rojo | Háptico de error | 300ms |
| Carga | Skeleton shimmer | — | variable |
| Firma completada | Transición suave a preview | Háptico ligero | 200ms |

### 11.2 Gestos táctiles

| Gesto | Acción |
|---|---|
| Tap largo en card equipo | Mostrar detalle rápido (popup) |
| Swipe left en préstamo activo | Opción "Devolver" directa |
| Swipe right en historial | Opción "Ver detalle" |
| Pull-to-refresh en listas | Recargar datos |

---

## 12. Diseño responsivo — Adaptaciones

### 12.1 Mobile (< 600px)

- BottomNavigation con 5 tabs
- Cards de ancho completo
- SignaturePad: 100% ancho
- Listas verticales
- FAB para acción principal

### 12.2 Tablet (600-1024px)

- BottomNavigation o NavigationRail (sidebar angosta)
- Grid de 2 columnas para equipos
- SignaturePad: 70% ancho, centrado
- Split view: lista + detalle lateral

### 12.3 Desktop (> 1024px)

- Sidebar fija con íconos + labels
- TopBar con búsqueda global
- Grid de 3-4 columnas para equipos
- SignaturePad: 400px fijo
- Modal/Dialog para crear préstamo (no pantalla completa)
- Atajos de teclado: `N` nuevo préstamo, `R` devolución, `/` buscar

---

## 13. Árbol de navegación completo (Go Router)

```
/login
    │
/dashboard (shell)
    │
    ├── /dashboard/prestamos                          → Lista de préstamos activos
    │   ├── /dashboard/prestamos/nuevo                → Crear préstamo (paso 1: docente)
    │   │   └── /dashboard/prestamos/nuevo/equipos    → Paso 2: seleccionar equipos
    │   │       └── /dashboard/prestamos/nuevo/firmar → Paso 3: firma
    │   │           └── /dashboard/prestamos/nuevo/confirmar → Confirmación
    │   └── /dashboard/prestamos/:id                  → Detalle del préstamo
    │
    ├── /dashboard/devoluciones/nuevo?prestamoId=:id  → Crear devolución
    │   └── /dashboard/devoluciones/nuevo/firmar      → Firma de devolución
    │       └── /dashboard/devoluciones/confirmar      → Confirmación
    │
    ├── /dashboard/equipos                            → Lista de equipos
    │   ├── /dashboard/equipos/nuevo                  → Formulario nuevo equipo
    │   └── /dashboard/equipos/:id                    → Detalle / editar
    │
    ├── /dashboard/docentes                           → Lista de docentes
    │   ├── /dashboard/docentes/nuevo                 → Formulario nuevo docente
    │   └── /dashboard/docentes/:id                   → Detalle / editar
    │
    └── /dashboard/historial                          → Historial con filtros
```

---

## 14. Resumen de componentes UI

| Componente | Mobile | Desktop | Estado |
|---|---|---|---|
| BottomNavigation | ✅ 5 tabs | ❌ Se reemplaza por Sidebar | — |
| Sidebar | ❌ | ✅ Expandible | — |
| SearchBar | ✅ Floating | ✅ En TopBar | — |
| SignaturePad | ✅ Full width | ✅ 400px centered | — |
| EquipoCard | ✅ Vertical list | ✅ Grid 3-4 cols | — |
| PrestamoCard | ✅ Swipeable | ✅ Clickable | — |
| FiltroChips | ✅ Horizontal scroll | ✅ Horizontal wrap | — |
| SkeletonLoader | ✅ | ✅ | — |
| ConfirmationSheet | ✅ Bottom sheet | ✅ Dialog | — |
| FAB | ✅ | ❌ Botón TopBar | — |
| Atajos teclado | ❌ | ✅ `N` `R` `/` | — |

---

## 15. Flujo de 15 segundos — paso a paso visual

```
Seg 0:  📱 Abrir app → Login automático (token vigente)
Seg 1:  📊 Dashboard visible
Seg 2:  👆 Tap "Nuevo préstamo"
Seg 3:  ⌨️ Escribe "Lu" → aparece Lucía Fernández
Seg 4:  👆 Tap Lucía Fernández
Seg 5:  📋 Lista de equipos visible (cacheada)
Seg 6:  👆 Tap HP ProBook
Seg 7:  👆 Tap Cargador HP
Seg 8:  👆 Tap Extensión
Seg 9:  👆 Tap "Firmar"
Seg 10: ✍️ Dibuja firma (2-3 seg)
Seg 13: 👆 Tap "Confirmar"
Seg 14: ✅ Animación de éxito + háptico
Seg 15: 👆 Tap "Nuevo préstamo" → listo para el siguiente
```

---

## 16. Paleta visual (recomendación)

| Rol | Color | Hex | Uso |
|---|---|---|---|
| Primario | Azul institucional | `#1565C0` | Botones, header, links |
| Secundario | Verde éxito | `#2E7D32` | Confirmación, disponible |
| Acento | Naranja warning | `#E65100` | Mantenimiento, alertas |
| Error | Rojo | `#C62828` | Errores, dado de baja |
| Fondo | Gris claro | `#F5F5F5` | Background general |
| Card | Blanco | `#FFFFFF` | Superficies |
| Texto | Gris oscuro | `#212121` | Body primario |

---

## 17. Resumen Fase 4

| Elemento | Estado |
|---|---|
| Flujo préstamo < 15 seg | ✅ Diseñado con desglose temporal |
| Flujo devolución < 10 seg | ✅ Diseñado con atajos |
| Dashboard métrico | ✅ Cards + lista activos + CTAs |
| Pantalla equipos | ✅ Filtros + búsqueda + historial por equipo |
| Pantalla docentes | ✅ Búsqueda + lista + estado activo/inactivo |
| Pantalla historial | ✅ Timeline + filtros avanzados |
| Captura firma | ✅ Canvas + upload Storage |
| Wireframes ASCII | ✅ 10 pantallas clave |
| Navegación Mobile | ✅ BottomNavigation + FAB |
| Navegación Desktop | ✅ Sidebar + TopBar + atajos teclado |
| Código Flutter | ❌ (Fase 5) |

> **Siguiente paso**: Fase 5 — Implementación Flutter: entidades, datasources, repositorios, providers y navegación base.
