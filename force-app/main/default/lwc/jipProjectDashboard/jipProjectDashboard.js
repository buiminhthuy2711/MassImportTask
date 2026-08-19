import { LightningElement, wire } from "lwc";
import getProjectList from "@salesforce/apex/JIP_ProjectDashboardController.getProjectList";

export default class JipProjectDashboard extends LightningElement {
    selectedProjectId;
    projectOptions = [];

    @wire(getProjectList)
    wiredProjects({ error, data }) {
        if (data) {
            this.projectOptions = data.map((p) => ({
                label: `${p.label} (${p.status})`,
                value: p.value
            }));
            if (this.projectOptions.length > 0 && !this.selectedProjectId) {
                this.selectedProjectId = this.projectOptions[0].value;
            }
        } else if (error) {
            console.error(error);
        }
    }

    handleProjectChange(event) {
        this.selectedProjectId = event.detail.value;
    }
}