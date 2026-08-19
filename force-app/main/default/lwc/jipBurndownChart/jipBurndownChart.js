import { LightningElement, api, wire } from "lwc";
import { loadScript } from "lightning/platformResourceLoader";
import chartJs from "@salesforce/resourceUrl/ChartJs";
import getBurndownData from "@salesforce/apex/JIP_ProjectDashboardController.getBurndownData";

export default class JipBurndownChart extends LightningElement {
    @api recordId;
    isLoading = true;
    burndownData;
    chart;
    chartJsLoaded = false;

    @wire(getBurndownData, { projectId: "$recordId" })
    wiredData({ error, data }) {
        if (data) {
            this.burndownData = data;
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
            if (this.burndownData) this.renderChart();
        } catch (e) {
            console.error("Chart.js load error", e);
        }
    }

    renderChart() {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            const canvas = this.refs.chartCanvas;
            if (!canvas || !this.burndownData) return;
            if (this.chart) this.chart.destroy();

            const { totalTasks, startDate, endDate, completedByDate } = this.burndownData;
            const start = new Date(startDate);
            const end = new Date(endDate);
            const today = new Date();
            const totalDays = Math.ceil((end - start) / 86400000);

            const labels = [];
            const idealLine = [];
            const actualLine = [];

            const completedMap = {};
            (completedByDate || []).forEach((d) => {
                completedMap[d.dt] = d.count;
            });

            const d = new Date(start);
            let cumulCompleted = 0;
            let dayIdx = 0;
            while (d <= end) {
                const key = d.toISOString().split("T")[0];
                const m = d.getMonth() + 1;
                const day = d.getDate();
                labels.push(`${m}/${day}`);
                idealLine.push(Math.max(0, totalTasks - (totalTasks / totalDays) * dayIdx));

                if (completedMap[key]) cumulCompleted += completedMap[key];
                actualLine.push(d <= today ? totalTasks - cumulCompleted : null);

                d.setDate(d.getDate() + 1);
                dayIdx++;
            }

            // eslint-disable-next-line no-undef
            this.chart = new Chart(canvas, {
                type: "line",
                data: {
                    labels,
                    datasets: [
                        {
                            label: "理想",
                            data: idealLine,
                            borderColor: "#aaa",
                            borderDash: [5, 5],
                            fill: false,
                            pointRadius: 0,
                            borderWidth: 2
                        },
                        {
                            label: "実績",
                            data: actualLine,
                            borderColor: "#2baf6a",
                            backgroundColor: "rgba(43,175,106,0.1)",
                            fill: true,
                            pointRadius: 2,
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
                            title: { display: true, text: "残タスク数" }
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