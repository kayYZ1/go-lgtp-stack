package main

import (
	"fmt"
	"net/http"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
	requestCount = prometheus.NewCounter(
		prometheus.CounterOpts{
			Name: "http_requests_total",
			Help: "Total number of HTTP requests",
		},
	)
)

func init() {
	prometheus.MustRegister(requestCount)
}

func handler(w http.ResponseWriter, r *http.Request) {
	requestCount.Inc()
	fmt.Fprintf(w, "Hello from Go server!")
}

func main() {
	http.HandleFunc("/", handler)
	http.Handle("/metrics", promhttp.Handler())

	fmt.Println("Running on 8081")
	http.ListenAndServe(":8081", nil)
}
