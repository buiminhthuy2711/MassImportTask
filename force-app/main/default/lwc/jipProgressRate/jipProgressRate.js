import { LightningElement, api, wire } from "lwc";
import getProgressRate from "@salesforce/apex/JIP_ProjectDashboardController.getProgressRate";

export default class JipProgressRate extends LightningElement {
    @api recordId;
    isLoading = true;
    completed = 0;
    total = 0;

    @wire(getProgressRate, { projectId: "$recordId" })
    wiredData({ error, data }) {
        this.isLoading = false;
        if (data) {
            this.total = data.total || 0;
            this.completed = data.completed || 0;
        } else if (error) {
            console.error("getProgressRate error", error);
        }
    }

    get remaining() {
        return this.total - this.completed;
    }

    get progressPercent() {
        if (this.total === 0) return 0;
        return Math.round((this.completed / this.total) * 100);
    }

    get circleStyle() {
        const pct = this.progressPercent;
        const color = pct >= 80 ? "#2baf6a" : pct >= 50 ? "#e8833a" : "#d9534f";
        return `background: conic-gradient(${color} ${pct * 3.6}deg, #e8e8e8 0deg)`;
    }
}