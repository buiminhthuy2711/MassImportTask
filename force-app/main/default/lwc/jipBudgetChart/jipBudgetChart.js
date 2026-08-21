import { LightningElement, api, wire } from "lwc";
import { loadScript } from "lightning/platformResourceLoader";
import chartJs from "@salesforce/resourceUrl/ChartJs";
import getBudgetVsActual from "@salesforce/apex/JIP_ProjectDashboardController.getBudgetVsActual";

export default class JipBudgetChart extends LightningElement {
    @api recordId;
    isLoading = true;
    budgetInfo = { budget: 0, actualCost: 0, remaining: 0 };
    chart;
    chartJsLoaded = false;

    @wire(getBudgetVsActual, { projectId: "$recordId" })
    wiredData({ error, data }) {
        if (data) {
            this.budgetInfo = data;
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
            if (!this.isLoading) this.renderChart();
        } catch (e) {
            console.error("Chart.js load error", e);
        }
    }

    formatNumber(n) {
        return Number(n || 0).toLocaleString();
    }

    get formattedBudget() {
        return this.formatNumber(this.budgetInfo.budget);
    }
    get formattedActual() {
        return this.formatNumber(this.budgetInfo.actualCost);
    }
    get formattedRemaining() {
        return this.formatNumber(this.budgetInfo.remaining);
    }
    get actualClass() {
        return "kpi-value " + (this.budgetInfo.actualCost > this.budgetInfo.budget ? "kpi-danger" : "kpi-actual");
    }
    get remainingClass() {
        return "kpi-value " + (this.budgetInfo.remaining < 0 ? "kpi-danger" : "kpi-remaining");
    }
    get usagePercent() {
        if (!this.budgetInfo.budget) return 0;
        return Math.round((this.budgetInfo.actualCost / this.budgetInfo.budget) * 100);
    }
    get progressBarStyle() {
        return `width: ${Math.min(this.usagePercent, 100)}%`;
    }
    get progressBarClass() {
        return "progress-fill " + (this.usagePercent > 90 ? "progress-danger" : "progress-ok");
    }

    renderChart() {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            const canvas = this.refs.chartCanvas;
            if (!canvas) return;
            if (this.chart) this.chart.destroy();

            // eslint-disable-next-line no-undef
            this.chart = new Chart(canvas, {
                type: "bar",
                data: {
                    labels: ["予算 vs 実績"],
                    datasets: [
                        {
                            label: "予算",
                            data: [this.budgetInfo.budget],
                            backgroundColor: "#5b9bd5",
                            borderRadius: 4,
                            barPercentage: 0.6
                        },
                        {
                            label: "実績",
                            data: [this.budgetInfo.actualCost],
                            backgroundColor: this.budgetInfo.actualCost > this.budgetInfo.budget ? "#d9534f" : "#2baf6a",
                            borderRadius: 4,
                            barPercentage: 0.6
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        y: {
                            beginAtZero: true,
                            title: { display: true, text: "金額 (¥)" }
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