import { LightningElement, api, wire } from "lwc";
import getCriticalPathData from "@salesforce/apex/JIP_ProjectDashboardController.getCriticalPathData";

export default class JipCriticalPathChart extends LightningElement {
    @api recordId;
    isLoading = true;
    tasks = [];
    minDate;
    maxDate;
    totalDays;

    @wire(getCriticalPathData, { projectId: "$recordId" })
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
            headers.push({ key: `d${i}`, label: `${d.getMonth() + 1}/${d.getDate()}` });
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

            return {
                id: t.id,
                priority: t.priority,
                subject: t.subject,
                subjectShort: t.subject.length > 18 ? t.subject.substring(0, 18) + "…" : t.subject,
                barStyle: `left: ${leftPct}%; width: ${widthPct}%;`,
                barClass: `gantt-bar ${t.isOverdue ? "bar-critical" : "bar-high"}`,
                priorityClass: `priority-badge pri-${t.priority}`,
                tooltip: `${t.subject} (${t.startDate} 〜 ${t.dueDate}) ${t.assigneeName || ""}`
            };
        });
    }
}