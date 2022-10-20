/**
 * @author danb@nebulaconsulting.co.uk
 * @date 20/10/2022
 */

public interface SlackHandler {
    void processMessages(List<SlackMessage> messages);
}