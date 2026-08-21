import { LightningElement, api, wire } from "lwc";
import { loadScript } from "lightning/platformResourceLoader";
import chartJs from "@salesforce/resourceUrl/ChartJs";
import getBugTrend from "@salesforce/apex/JIP_ProjectDashboardController.getBugTrend";
import getBugFixTrend from "@salesforce/apex/JIP_ProjectDashboardController.getBugFixTrend";

export default class JipBugTrendChart extends LightningElement {
  @api recordId;
  isLoading = true;
  bugData = [];
  fixData = [];
  loadCount = 0;
  chart;
  chartJsLoaded = false;

  @wire(getBugTrend, { projectId: "$recordId" })
  wiredBugs({ error, data }) {
    if (data) {
      this.bugData = data;
      this.checkReady();
    } else if (error) {
      console.error(error);
      this.checkReady();
    }
  }

  @wire(getBugFixTrend, { projectId: "$recordId" })
  wiredFixes({ error, data }) {
    if (data) {
      this.fixData = data;
      this.checkReady();
    } else if (error) {
      console.error(error);
      this.checkReady();
    }
  }

  checkReady() {
    this.loadCount++;
    if (this.loadCount >= 2) {
      this.isLoading = false;
      if (this.chartJsLoaded) this.renderChart();
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

  renderChart() {
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    setTimeout(() => {
      const canvas = this.refs.chartCanvas;
      if (!canvas) return;
      if (this.chart) this.chart.destroy();

      // Merge all dates
      const dateSet = new Set();
      this.bugData.forEach((d) => dateSet.add(d.dt));
      this.fixData.forEach((d) => dateSet.add(d.dt));
      const sortedDates = [...dateSet].sort();

      const bugMap = {};
      this.bugData.forEach((d) => {
        bugMap[d.dt] = d.count;
      });
      const fixMap = {};
      this.fixData.forEach((d) => {
        fixMap[d.dt] = d.count;
      });

      const labels = sortedDates.map((dt) => {
        const d = new Date(dt);
        return `${d.getMonth() + 1}/${d.getDate()}`;
      });

      const bugValues = sortedDates.map((dt) => bugMap[dt] || 0);
      const fixValues = sortedDates.map((dt) => fixMap[dt] || 0);
      const isFewPoints = sortedDates.length <= 2;
      const chartType = isFewPoints ? "bar" : "line";

      const lineProps = isFewPoints ? {} : { fill: true, tension: 0.3 };

      // eslint-disable-next-line no-undef
      this.chart = new Chart(canvas, {
        type: chartType,
        data: {
          labels,
          datasets: [
            {
              label: "発生バグ数",
              data: bugValues,
              borderColor: "#d9534f",
              backgroundColor: isFewPoints
                ? "rgba(217,83,79,0.6)"
                : "rgba(217,83,79,0.1)",
              borderWidth: 2,
              pointRadius: 5,
              pointBackgroundColor: "#d9534f",
              ...lineProps
            },
            {
              label: "修正数",
              data: fixValues,
              borderColor: "#2baf6a",
              backgroundColor: isFewPoints
                ? "rgba(43,175,106,0.6)"
                : "rgba(43,175,106,0.1)",
              borderWidth: 2,
              pointRadius: 5,
              pointBackgroundColor: "#2baf6a",
              ...lineProps
            }
          ]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          scales: {
            y: {
              beginAtZero: true,
              title: { display: true, text: "バグ数" },
              ticks: { stepSize: 1 }
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