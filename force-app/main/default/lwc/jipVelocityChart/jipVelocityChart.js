import { LightningElement, api, wire } from "lwc";
import { loadScript } from "lightning/platformResourceLoader";
import chartJs from "@salesforce/resourceUrl/ChartJs";
import getVelocityData from "@salesforce/apex/JIP_ProjectDashboardController.getVelocityData";

export default class JipVelocityChart extends LightningElement {
    @api recordId;
    isLoading = true;
    velocityData = [];
    chart;
    chartJsLoaded = false;

    @wire(getVelocityData, { projectId: "$recordId" })
    wiredData({ error, data }) {
        if (data) {
            this.velocityData = data;
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
            if (this.velocityData.length > 0) this.renderChart();
        } catch (e) {
            console.error("Chart.js load error", e);
        }
    }

    get hasData() {
        return this.velocityData.length > 0;
    }

    get averageVelocity() {
        if (this.velocityData.length === 0) return 0;
        const sum = this.velocityData.reduce((a, b) => a + b.points, 0);
        return Math.round((sum / this.velocityData.length) * 10) / 10;
    }

    renderChart() {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            const canvas = this.refs.chartCanvas;
            if (!canvas) return;
            if (this.chart) this.chart.destroy();

            const labels = this.velocityData.map((d) => d.sprint);
            const values = this.velocityData.map((d) => d.points);
            const avg = this.averageVelocity;

            // eslint-disable-next-line no-undef
            this.chart = new Chart(canvas, {
                type: "bar",
                data: {
                    labels,
                    datasets: [
                        {
                            label: "完了ポイント",
                            data: values,
                            backgroundColor: "#5b9bd5",
                            borderRadius: 4
                        },
                        {
                            label: "平均",
                            data: labels.map(() => avg),
                            type: "line",
                            borderColor: "#e8833a",
                            borderDash: [5, 5],
                            pointRadius: 0,
                            fill: false,
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
                            title: { display: true, text: "Story Points" }
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