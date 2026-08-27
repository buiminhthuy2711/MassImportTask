public class JIP_ProjectTaskImportQueueable implements Queueable{
    private Id contentVersionId;
    private Id projectId;
    private String userEmail;
    private String fileName;

    public JIP_ProjectTaskImportQueueable(
         Id contentVersionId,
         Id projectId,
         String userEmail,
         String fileName
    )
    {
        this.contentVersionId = contentVersionId;
        this.projectId = projectId;
        this.userEmail = userEmail;
        this.fileName = fileName;
    }
    public void execute(QueueableContext context) {
        Integer totalCount = 0;
        Integer successCount = 0;
        Integer errorCount = 0;
    }
}
