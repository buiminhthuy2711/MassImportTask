import { LightningElement, api, wire } from "lwc";
import { loadScript } from "lightning/platformResourceLoader";
import chartJs from "@salesforce/resourceUrl/ChartJs";
import getSCurveData from "@salesforce/apex/JIP_ProjectDashboardController.getSCurveData";

export default class JipSCurveChart extends LightningElement {
    @api recordId;
    isLoading = true;
    curveData;
    chart;
    chartJsLoaded = false;
    _gapTasks = 0;

    @wire(getSCurveData, { projectId: "$recordId" })
    wiredData({ error, data }) {
        if (data) {
            this.curveData = data;
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
            if (this.curveData) this.renderChart();
        } catch (e) {
            console.error("Chart.js load error", e);
        }
    }

    get hasGap() {
        return this._gapTasks !== 0;
    }

    get gapTasks() {
        return this._gapTasks;
    }

    renderChart() {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            const canvas = this.refs.chartCanvas;
            if (!canvas || !this.curveData) return;
            if (this.chart) this.chart.destroy();

            const { startDate, endDate, totalTasks, plannedByDate, actualByDate } = this.curveData;
            const start = new Date(startDate);
            const end = new Date(endDate);
            const today = new Date();

            const plannedMap = {};
            (plannedByDate || []).forEach((d) => {
                plannedMap[d.dt] = (plannedMap[d.dt] || 0) + d.count;
            });
            const actualMap = {};
            (actualByDate || []).forEach((d) => {
                actualMap[d.dt] = (actualMap[d.dt] || 0) + d.count;
            });

            const labels = [];
            const plannedLine = [];
            const actualLine = [];
            let cumulPlanned = 0;
            let cumulActual = 0;

            const d = new Date(start);
            while (d <= end) {
                const key = d.toISOString().split("T")[0];
                labels.push(`${d.getMonth() + 1}/${d.getDate()}`);

                if (plannedMap[key]) cumulPlanned += plannedMap[key];
                plannedLine.push(cumulPlanned);

                if (actualMap[key]) cumulActual += actualMap[key];
                actualLine.push(d <= today ? cumulActual : null);

                d.setDate(d.getDate() + 1);
            }

            this._gapTasks = cumulPlanned - cumulActual;

            // eslint-disable-next-line no-undef
            this.chart = new Chart(canvas, {
                type: "line",
                data: {
                    labels,
                    datasets: [
                        {
                            label: "計画（累積）",
                            data: plannedLine,
                            borderColor: "#5b9bd5",
                            borderDash: [5, 5],
                            fill: false,
                            pointRadius: 0,
                            borderWidth: 2
                        },
                        {
                            label: "実績（累積）",
                            data: actualLine,
                            borderColor: "#2baf6a",
                            backgroundColor: "rgba(43,175,106,0.08)",
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
                            max: totalTasks > 0 ? totalTasks : undefined,
                            title: { display: true, text: "完了タスク数（累積）" }
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