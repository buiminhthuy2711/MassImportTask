import { LightningElement, api, wire } from "lwc";
import { loadScript } from "lightning/platformResourceLoader";
import chartJs from "@salesforce/resourceUrl/ChartJs";
import getCompletionTrend from "@salesforce/apex/JIP_ProjectDashboardController.getCompletionTrend";

export default class JipCompletionTrend extends LightningElement {
    @api recordId;
    isLoading = true;
    trendData = [];
    chart;
    chartJsLoaded = false;

    @wire(getCompletionTrend, { projectId: "$recordId" })
    wiredData({ error, data }) {
        if (data) {
            this.trendData = data;
            this.isLoading = false;
            if (this.chartJsLoaded) this.renderChart();
        } else if (error) {
            console.error(error);
            this.isLoading = false;
        }
    }

    async renderedCallback() {
        if (this.chartJsLoaded) return;
        try {
            await loadScript(this, chartJs);
            this.chartJsLoaded = true;
            if (this.trendData.length > 0) this.renderChart();
        } catch (e) {
            console.error("Chart.js load error", e);
        }
    }

    renderChart() {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            const canvas = this.refs.chartCanvas;
            if (!canvas) return;
            if (this.chart) this.chart.destroy();

            const labels = this.trendData.map((d) => {
                const dt = new Date(d.dt);
                return `${dt.getMonth() + 1}/${dt.getDate()}`;
            });
            const values = this.trendData.map((d) => d.count);

            // eslint-disable-next-line no-undef
            this.chart = new Chart(canvas, {
                type: "line",
                data: {
                    labels,
                    datasets: [
                        {
                            label: "完了数",
                            data: values,
                            borderColor: "#2baf6a",
                            backgroundColor: "rgba(43,175,106,0.15)",
                            fill: true,
                            tension: 0.3,
                            pointRadius: 3,
                            borderWidth: 2
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        y: {
                            beginAtZero: true,
                            title: { display: true, text: "完了タスク数" },
                            ticks: { stepSize: 1 }
                        }
                    },
                    plugins: {
                        legend: { display: false }
                    }
                }
            });
        }, 0);
    }
}