import { LightningElement, api, wire } from "lwc";
import { loadScript } from "lightning/platformResourceLoader";
import chartJs from "@salesforce/resourceUrl/ChartJs";
import getOverdueTasks from "@salesforce/apex/JIP_ProjectDashboardController.getOverdueTasks";
import getOverdueCount from "@salesforce/apex/JIP_ProjectDashboardController.getOverdueCount";

export default class JipOverdueChart extends LightningElement {
    @api recordId;
    isLoading = true;
    overdueData = [];
    overdueCount = 0;
    loadCount = 0;
    chart;
    chartJsLoaded = false;

    @wire(getOverdueTasks, { projectId: "$recordId" })
    wiredData({ error, data }) {
        if (data) {
            this.overdueData = data;
        } else if (error) {
            console.error(error);
        }
        this.checkReady();
    }

    @wire(getOverdueCount, { projectId: "$recordId" })
    wiredCount({ error, data }) {
        if (data !== undefined) {
            this.overdueCount = data;
        } else if (error) {
            console.error(error);
        }
        this.checkReady();
    }

    checkReady() {
        this.loadCount++;
        if (this.loadCount >= 2) {
            this.isLoading = false;
            if (this.chartJsLoaded && this.overdueData.length > 0) this.renderChart();
        }
    }

    async renderedCallback() {
        if (this.chartJsLoaded) return;
        try {
            await loadScript(this, chartJs);
            this.chartJsLoaded = true;
            if (!this.isLoading && this.overdueData.length > 0) this.renderChart();
        } catch (e) {
            console.error("Chart.js load error", e);
        }
    }

    get hasData() {
        return this.overdueData.length > 0;
    }

    get alertClass() {
        return this.overdueCount > 0 ? "alert-badge alert-danger" : "alert-badge alert-ok";
    }

    renderChart() {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            const canvas = this.refs.chartCanvas;
            if (!canvas) return;
            if (this.chart) this.chart.destroy();

            const labels = this.overdueData.map((d) => d.assigneeName);
            const values = this.overdueData.map((d) => d.count);

            // eslint-disable-next-line no-undef
            this.chart = new Chart(canvas, {
                type: "bar",
                data: {
                    labels,
                    datasets: [
                        {
                            label: "遅延タスク数",
                            data: values,
                            backgroundColor: "#d9534f",
                            borderRadius: 4
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    indexAxis: "y",
                    scales: {
                        x: {
                            beginAtZero: true,
                            ticks: { stepSize: 1 },
                            title: { display: true, text: "タスク数" }
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