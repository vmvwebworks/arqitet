# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"  
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# ApexCharts como alternativa compatible a Chartkick
pin "apexcharts", to: "https://cdn.jsdelivr.net/npm/apexcharts@3.45.2/dist/apexcharts.esm.js"

# Splide.js como alternativa compatible a Swiper
pin "@splidejs/splide", to: "https://cdn.jsdelivr.net/npm/@splidejs/splide@4.1.4/dist/js/splide.esm.js"
