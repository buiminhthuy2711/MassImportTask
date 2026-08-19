import { LightningElement, api, wire } from "lwc";
import getGanttData from "@salesforce/apex/JIP_ProjectDashboardController.getGanttData";

export default class JipGanttChart extends LightningElement {
    @api recordId;
    isLoading = true;
    tasks = [];
    minDate;
    maxDate;
    totalDays;

    @wire(getGanttData, { projectId: "$recordId" })
    wiredData({ error, data }) {
        this.isLoading = false;
        if (data && data.length > 0) {
            this.tasks = data;
            this.calculateDateRange();
        } else if (error) {
            console.error(error);
        }
    }

    calculateDateRange() {
        let min = null;
        let max = null;
        this.tasks.forEach((t) => {
            const s = new Date(t.startDate);
            const e = new Date(t.dueDate);
            if (!min || s < min) min = s;
            if (!max || e > max) max = e;
        });
        // Add padding
        min.setDate(min.getDate() - 2);
        max.setDate(max.getDate() + 2);
        this.minDate = min;
        this.maxDate = max;
        this.totalDays = Math.ceil((max - min) / 86400000) + 1;
    }

    get hasData() {
        return this.tasks.length > 0;
    }

    get dateHeaders() {
        if (!this.minDate) return [];
        const headers = [];
        const d = new Date(this.minDate);
        for (let i = 0; i < this.totalDays; i++) {
            const m = d.getMonth() + 1;
            const day = d.getDate();
            headers.push({ key: `d${i}`, label: `${m}/${day}` });
            d.setDate(d.getDate() + 1);
        }
        return headers;
    }

    get ganttRows() {
        if (!this.minDate) return [];
        return this.tasks.map((t) => {
            const start = new Date(t.startDate);
            const end = new Date(t.dueDate);
            const offsetDays = Math.max(0, Math.ceil((start - this.minDate) / 86400000));
            const durationDays = Math.max(1, Math.ceil((end - start) / 86400000) + 1);
            const leftPct = (offsetDays / this.totalDays) * 100;
            const widthPct = (durationDays / this.totalDays) * 100;

            const statusColors = {
                未対応: "bar-notstarted",
                処理中: "bar-inprogress",
                処理済み: "bar-resolved",
                完了: "bar-done"
            };

            return {
                id: t.id,
                taskKey: t.taskKey,
                subject: t.subject,
                subjectShort: t.subject.length > 20 ? t.subject.substring(0, 20) + "…" : t.subject,
                barStyle: `left: ${leftPct}%; width: ${widthPct}%;`,
                barClass: `gantt-bar ${statusColors[t.status] || "bar-default"} ${t.isOverdue ? "bar-overdue" : ""}`,
                statusClass: `task-key-badge st-${t.status}`,
                tooltip: `${t.subject} (${t.startDate} 〜 ${t.dueDate}) ${t.assigneeName || ""}`
            };
        });
    }
}