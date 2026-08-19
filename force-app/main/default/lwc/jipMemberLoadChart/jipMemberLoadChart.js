import { LightningElement, api, wire } from "lwc";
import { loadScript } from "lightning/platformResourceLoader";
import chartJs from "@salesforce/resourceUrl/ChartJs";
import getMemberTaskLoad from "@salesforce/apex/JIP_ProjectDashboardController.getMemberTaskLoad";

export default class JipMemberLoadChart extends LightningElement {
    @api recordId;
    isLoading = true;
    loadData = [];
    chart;
    chartJsLoaded = false;

    @wire(getMemberTaskLoad, { projectId: "$recordId" })
    wiredData({ error, data }) {
        if (data) {
            this.loadData = data;
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
            if (this.loadData.length > 0) this.renderChart();
        } catch (e) {
            console.error("Chart.js load error", e);
        }
    }

    get hasData() {
        return this.loadData.length > 0;
    }

    renderChart() {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            const canvas = this.refs.chartCanvas;
            if (!canvas) return;
            if (this.chart) this.chart.destroy();

            const labels = this.loadData.map((d) => d.memberName);

            // eslint-disable-next-line no-undef
            this.chart = new Chart(canvas, {
                type: "bar",
                data: {
                    labels,
                    datasets: [
                        {
                            label: "未対応",
                            data: this.loadData.map((d) => d.notStarted),
                            backgroundColor: "#ff6666",
                            borderRadius: 2
                        },
                        {
                            label: "処理中",
                            data: this.loadData.map((d) => d.inProgress),
                            backgroundColor: "#4db87e",
                            borderRadius: 2
                        },
                        {
                            label: "処理済み",
                            data: this.loadData.map((d) => d.resolved),
                            backgroundColor: "#5599dd",
                            borderRadius: 2
                        },
                        {
                            label: "完了",
                            data: this.loadData.map((d) => d.done),
                            backgroundColor: "#aaaaaa",
                            borderRadius: 2
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        x: { stacked: true },
                        y: {
                            stacked: true,
                            beginAtZero: true,
                            ticks: { stepSize: 1 },
                            title: { display: true, text: "タスク数" }
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