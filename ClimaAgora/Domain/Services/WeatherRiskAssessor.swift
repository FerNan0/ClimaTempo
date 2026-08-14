import Foundation

// MARK: - WeatherRiskAssessor
//
// Deriva avisos de risco a partir do clima ATUAL, de forma determinística e
// on-device — nada de LLM aqui (anti-alucinação: um aviso de segurança não pode
// inventar). Cada limiar é explícito e testável, o que também serve de evidência
// empírica no TCC.
//
// IMPORTANTE (unidade do vento): a OpenWeather com `units=metric` devolve a
// velocidade do vento em **m/s** — é o valor cru em `weather.windSpeed`. Os
// limiares abaixo são em m/s (o `evaluate` antigo comparava com 40/60 como se
// fosse km/h, então o risco de vento nunca disparava — a "ventania" passava batido).

enum WeatherRiskAssessor {

    // Limiares (documentados para o TCC)
    private enum T {
        static let windAttention = 8.0    // m/s (~29 km/h) — vira difícil andar / guarda-chuva
        static let windDanger    = 13.0   // m/s (~47 km/h) — pode derrubar galhos e objetos
        static let heatAttention = 33.0   // °C sensação
        static let heatDanger    = 39.0
        static let coldAttention = 8.0
        static let coldDanger    = 3.0
        static let uvAttention   = 6.0
        static let uvDanger      = 9.0
        static let fogVisibility = 1500.0 // metros
        static let rainSoonPop   = 80.0   // % de chance na previsão de hoje
    }

    /// Avalia o clima e devolve os riscos ATIVOS (vazio = sem risco).
    /// Ordena do mais grave para o menos grave.
    static func assess(weather: Weather, forecast: [DailyForecast] = []) -> [WeatherRisk] {
        var risks: [WeatherRisk] = []
        let condition = weather.condition.lowercased()
        let wind = weather.windSpeed          // m/s
        let feels = weather.feelsLike
        let uv = weather.uvIndex
        let visibility = Double(weather.visibility)

        // Tempestade (raios) — sempre o mais crítico
        if condition.contains("thunder") || condition.contains("squall") {
            risks.append(WeatherRisk(
                hazard: .storm, level: .danger, emoji: "⛈️",
                title: "Tempestade com raios",
                whatCanHappen: "Risco de raios, chuva forte e alagamento.",
                whatToDo: "Fique em local coberto. Não se abrigue embaixo de árvores."))
        }

        // Vento
        if wind >= T.windDanger {
            risks.append(WeatherRisk(
                hazard: .wind, level: .danger, emoji: "💨",
                title: "Ventania",
                whatCanHappen: "Pode derrubar galhos, objetos soltos e atrapalhar o equilíbrio.",
                whatToDo: "Evite a praia, árvores e áreas abertas. Segure bem seus pertences."))
        } else if wind >= T.windAttention {
            risks.append(WeatherRisk(
                hazard: .wind, level: .attention, emoji: "💨",
                title: "Vento forte",
                whatCanHappen: "Pode dificultar caminhar e virar o guarda-chuva.",
                whatToDo: "Cuidado perto do mar e em lugares altos. Segure bem seus pertences."))
        }

        // Chuva (agora ou a caminho)
        let isRaining = condition.contains("rain") || condition.contains("drizzle")
        let rainSoon = forecast.first.map { $0.precipitation >= T.rainSoonPop } ?? false
        if isRaining {
            risks.append(WeatherRisk(
                hazard: .rain, level: .attention, emoji: "🌧️",
                title: "Chuva",
                whatCanHappen: "As ruas ficam molhadas e escorregadias.",
                whatToDo: "Leve guarda-chuva ou capa. No trânsito, vá com mais atenção."))
        } else if rainSoon {
            risks.append(WeatherRisk(
                hazard: .rain, level: .attention, emoji: "🌦️",
                title: "Chuva a caminho",
                whatCanHappen: "Deve chover mais tarde hoje.",
                whatToDo: "Já saia com guarda-chuva, por garantia."))
        }

        // Calor / Frio (usa a sensação térmica)
        if feels >= T.heatDanger {
            risks.append(WeatherRisk(
                hazard: .heat, level: .danger, emoji: "🥵",
                title: "Calor extremo",
                whatCanHappen: "Risco à saúde, principalmente para idosos e crianças.",
                whatToDo: "Fique na sombra, beba muita água e evite esforço no sol."))
        } else if feels >= T.heatAttention {
            risks.append(WeatherRisk(
                hazard: .heat, level: .attention, emoji: "☀️",
                title: "Calor forte",
                whatCanHappen: "Pode dar cansaço e desidratação.",
                whatToDo: "Beba água, use protetor solar e evite o sol do meio-dia."))
        } else if feels <= T.coldDanger {
            risks.append(WeatherRisk(
                hazard: .cold, level: .danger, emoji: "🥶",
                title: "Frio intenso",
                whatCanHappen: "Risco de hipotermia com exposição longa.",
                whatToDo: "Agasalhe-se em camadas e evite ficar muito tempo na rua."))
        } else if feels <= T.coldAttention {
            risks.append(WeatherRisk(
                hazard: .cold, level: .attention, emoji: "🧥",
                title: "Frio",
                whatCanHappen: "O vento pode aumentar a sensação de frio.",
                whatToDo: "Agasalhe-se bem antes de sair."))
        }

        // Sol forte (UV) — só dispara se a API trouxer índice UV
        if uv >= T.uvDanger {
            risks.append(WeatherRisk(
                hazard: .uv, level: .danger, emoji: "🧴",
                title: "Sol muito forte (UV extremo)",
                whatCanHappen: "A pele queima em poucos minutos.",
                whatToDo: "Evite o sol das 10h às 16h. Use protetor, boné e óculos."))
        } else if uv >= T.uvAttention {
            risks.append(WeatherRisk(
                hazard: .uv, level: .attention, emoji: "🕶️",
                title: "Sol forte (UV alto)",
                whatCanHappen: "A pele pode queimar rápido.",
                whatToDo: "Use protetor solar, boné e óculos de sol."))
        }

        // Neblina / baixa visibilidade
        if visibility > 0 && visibility < T.fogVisibility {
            risks.append(WeatherRisk(
                hazard: .fog, level: .attention, emoji: "🌫️",
                title: "Neblina",
                whatCanHappen: "Pouca visibilidade nas ruas e estradas.",
                whatToDo: "Se for dirigir, vá devagar e com farol baixo."))
        }

        // Mais grave primeiro; empate mantém a ordem de inserção (prioridade acima).
        return risks.sorted { $0.level > $1.level }
    }

    /// Nível geral (o mais grave entre os riscos) — alimenta o semáforo 🟢🟡🔴.
    static func overallLevel(_ risks: [WeatherRisk]) -> WeatherRisk.Level {
        risks.map(\.level).max() ?? .safe
    }
}
