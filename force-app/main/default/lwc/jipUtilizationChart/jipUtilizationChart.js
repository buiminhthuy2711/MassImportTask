import { LightningElement, api, wire } from "lwc";
import { loadScript } from "lightning/platformResourceLoader";
import chartJs from "@salesforce/resourceUrl/ChartJs";
import getUtilizationData from "@salesforce/apex/JIP_ProjectDashboardController.getUtilizationData";

export default class JipUtilizationChart extends LightningElement {
    @api recordId;
    isLoading = true;
    utilData = [];
    chart;
    chartJsLoaded = false;

    @wire(getUtilizationData, { projectId: "$recordId" })
    wiredData({ error, data }) {
        if (data) {
            this.utilData = data.map((d) => ({
                ...d,
                rateClass: d.utilizationRate > 100 ? "util-col util-over" : "util-col util-normal"
            }));
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
            if (this.utilData.length > 0) this.renderChart();
        } catch (e) {
            console.error("Chart.js load error", e);
        }
    }

    get hasData() {
        return this.utilData.length > 0;
    }

    renderChart() {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            const canvas = this.refs.chartCanvas;
            if (!canvas) return;
            if (this.chart) this.chart.destroy();

            const labels = this.utilData.map((d) => d.memberName);

            // eslint-disable-next-line no-undef
            this.chart = new Chart(canvas, {
                type: "bar",
                data: {
                    labels,
                    datasets: [
                        {
                            label: "予定時間",
                            data: this.utilData.map((d) => d.estimatedHours),
                            backgroundColor: "#5b9bd5",
                            borderRadius: 4
                        },
                        {
                            label: "実績時間",
                            data: this.utilData.map((d) => d.actualHours),
                            backgroundColor: "#2baf6a",
                            borderRadius: 4
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        y: {
                            beginAtZero: true,
                            title: { display: true, text: "時間 (h)" }
                        }
                    },
                    plugins: {
                        legend: { position: "top" }
                    }
                }
            });
        }, 0);
    }
}