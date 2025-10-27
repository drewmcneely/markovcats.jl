Pressure <- FinSet
Pressure = {High, Low}

Weather <- FinSet
Weather = {Sunny, Cloudy, Rainy}

p : Pressure
p(High) = 0.80
p(Low) = 0.20

f : Pressure -> Weather
f(Sunny | High) = 0.60
f(Cloudy | High) = 0.20
f(Rainy | High) = 0.20

f(Sunny | Low) = 0.10
f(Cloudy | Low) = 0.20
f(Rainy | Low) = 0.70

w : Weather
w(Weather) = sum_Pressure f(Weather | Pressure) p(Pressure)
