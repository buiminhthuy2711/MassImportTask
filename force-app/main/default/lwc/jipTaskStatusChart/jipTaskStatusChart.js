import { LightningElement, api, wire } from "lwc";
import { loadScript } from "lightning/platformResourceLoader";
import chartJs from "@salesforce/resourceUrl/ChartJs";
import getTaskStatusDistribution from "@salesforce/apex/JIP_ProjectDashboardController.getTaskStatusDistribution";

const STATUS_COLORS = {
    未対応: "#ff6666",
    処理中: "#4db87e",
    処理済み: "#5599dd",
    完了: "#aaaaaa"
};

export default class JipTaskStatusChart extends LightningElement {
    @api recordId;
    isLoading = true;
    chartData = [];
    chart;
    chartJsLoaded = false;

    @wire(getTaskStatusDistribution, { projectId: "$recordId" })
    wiredData({ error, data }) {
        if (data) {
            this.chartData = data;
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
            if (this.chartData.length > 0) this.renderChart();
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

            const labels = this.chartData.map((d) => d.status);
            const values = this.chartData.map((d) => d.count);
            const colors = labels.map((l) => STATUS_COLORS[l] || "#ccc");

            // eslint-disable-next-line no-undef
            this.chart = new Chart(canvas, {
                type: "doughnut",
                data: {
                    labels,
                    datasets: [{ data: values, backgroundColor: colors, borderWidth: 2, borderColor: "#fff" }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    cutout: "55%",
                    plugins: {
                        legend: { display: false }
                    }
                }
            });
        }, 0);
    }

    get legendItems() {
        return this.chartData.map((d) => ({
            label: d.status,
            count: d.count,
            dotStyle: `background-color: ${STATUS_COLORS[d.status] || "#ccc"}`
        }));
    }
}