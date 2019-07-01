/**
 * TopicService provides services and methods related to the Topic Object.
 *
 * @author  Rodrigue Poon
 * @since   2018-03-23
 *
 * @editor Jason Tam
 * @version 2.4
 * @last edit 2018-08-03
 *
 * remove redundence
 *
 */

public class TopicService {

//---Assign the already existing topics to new Feed Item---//
public static void assignTopicToFeedItem(FeedItem feedItem, String topicId, String topicName, List<String> topicsOnExclusion) {
    //Check whether the topic to be assigned is on the exclusion list. Assign the topic if it is not on the list
    if (!topicsOnExclusion.contains(topicName.toLowerCase())) {
        TopicAssignment topicAssignment = new TopicAssignment();
        topicAssignment.TopicId = topicId;
        topicAssignment.EntityId = feedItem.Id;
        insert topicAssignment;
    }
}


//---Creates a new topic record in Salesforce---//
public static void createNewTopic(String newTopic) {
    try{
        Topic newTopicToCreate = new Topic(Name = newTopic);
        insert newTopicToCreate;
    } catch (DmlException e) {
        System.debug('An error has occured when inserting a new record to Topic: ' + e.getMessage());
    }
}


//Turn the symbols to space and split the string according to the space
public static List<String> SplitStringWithSpace(String input){
    List<String> output = new List<String>();
    String removeJava = input.replace('\\u00A0', ' ');
    //'copy and paste' sometimes bring some extra formatting rich text to the chatter post
    // - the above coding can remove the non shown words followed by the space

    String removeghost = removeJava.replace('&AMP;AMP;', ' & ');
    String removeghost2 = removeghost.replace('&AMP;#39;', '\'');   // the '\' will not be split i.e. J'C != J+'+C
    String removeghost3 = removeghost2.replace('.', ' . ');
    String removeghost4 = removeghost3.replace('?', ' ? ');
    String removeghost5 = removeghost4.replace(':', ' : ');
    String removeghost6 = removeghost5.replace('<P>', ' a ');
    String removeghost7 = removeghost6.replace('</P>', ' a ');
    String removeghost8 = removeghost7.replace(' &NBSP; ', '  ');
    removeghost8 = removeghost8.replace('&NBSP;', ' ');
    String removeghost9 = removeghost8.replace('&NBSP ;', ' ');
    String removeghost10 = removeghost9.replace(' &AMP;QUOT; ', '  "  ');
    removeghost10 = removeghost10.replace('&AMP;QUOT;',' " ');
    String removeghost11 = removeghost10.replace('(', ' a ');
    String removeghost12 = removeghost11.replace(')', ' a ');
    String removeghost13 = removeghost12.replace('<BR>', ' a ');
    String removeghost14 = removeghost13.replace('</BR>', ' a ');
    String removeghost15 = removeghost14.replace('!', ' ! ');
    String removeghost16 = removeghost15.replace(',', ' , ');
    String removeghost17 = removeghost16.replace(' &AMP;LT; ', '  <  ');
    removeghost17 = removeghost17.replace('&AMP;LT;', ' < ');
    String removeghost18 = removeghost17.replace(' &AMP;GT; ', '  >  ');
    removeghost18 = removeghost18.replace('&AMP;GT;', ' > ');
    String removeghost19 = removeghost18.replace(' &AMP;QUOT ', '  "  ');
    removeghost19 = removeghost19.replace('&AMP;QUOT', ' " ');
    String removeghost20 = removeghost19.replace(' &AMP;FRASL; ', '  /  ');
    removeghost20 = removeghost20.replace('&AMP;FRASL;', ' / ');
    String removeghost21 = removeghost20.replace(' &AMP;OLINE; ', '  -  ');
    removeghost21 = removeghost21.replace('&AMP;OLINE;', ' - ');
    String removeghost22 = removeghost21.replace(' &LT; ', '  <  ');
    removeghost22 = removeghost22.replace('&LT;', ' < ');
    String removeghost23 = removeghost22.replace(' &GT; ', '  >  ');
    removeghost23 = removeghost23.replace('&GT;', ' > ');
    String removeghost24 = removeghost23.replace(' &QUOT ', '  "  ');
    removeghost24 = removeghost24.replace('&QUOT', ' " ');
    String removeghost25 = removeghost24.replace(' &FRASL; ', '  /  ');
    removeghost25 = removeghost25.replace('&FRASL;', ' / ');
    String removeghost26 = removeghost25.replace(' &OLINE; ', '  -  ');
    removeghost26 = removeghost26.replace('&OLINE;', ' - ');
    String removeghost27 = removeghost26.replace('/', ' / ');
    String removeghost28 = removeghost27.replace(';', ' ; ');
    String removeghost29 = removeghost28.replace('  ', ' a ');
    // Until now, there are 29 items that may affect the comparison result and were escaped
    // The .replace() for the same item is used to avoid infinity space bar
    // removeghost30 will divide all the double space
    // i.e. 'Brooks Brothers;' -> 'Brooks Brothers ; '
    // i.e. 'Brooks  Brothers' -> 'Brooks a Brothers'
    // i.e. 'J.C. Penney' -> 'J . C .  Penney' -> 'J . C . a Penney'
    // - However, the conditions in handler include .equal(). Nickname 'J.C. Penney' still can be recognized

    List<String> splitWithSpace = removeghost29.split(' ');
    //sometime split() misses one or two, double split is needed
    List<String> doublesplit = new List<String>();
    for(String temp : splitWithSpace) {
        List<String> splitTemp = temp.split(' ');
        for(String temp2 : splitTemp)
            if(!temp2.equals('') && !temp2.equals(' '))     //avoid null pointer
                doublesplit.add(temp2);
    }
    for(String temp : doublesplit) {
        if(!temp.equals(null) && !temp.equals(' '))     // avoid null pointer
            output.add(temp);
    }
    return output;
}

//Turn the two string to upper case and compare them
public static boolean checkWhetherFeedItemContainsTopicCaseInsensitive(String feedItemBody, String topic){
    boolean feedItemBodyContainsTopic = false;
    //version 1.1 variable to determine whether exact wording should be applied

    if(feedItemBody == null) return false;
    //drop when null body is found(often occurs on RSS)

    //Split the feedItem, turn it into upper case and determine whether it contains only one word
    String removehtml = feedItemBody.escapeHtml4().escapeJava();
    //the above functions catch the rich text and html tag
    String caseInsensitiveFeedItem = removehtml.toUpperCase();
    List<String>feedItemBodyList = SplitStringWithSpace(caseInsensitiveFeedItem);
    boolean feedItemContainsMoreThanOneWord = false;
    if(feedItemBodyList.size() > 1 && !feedItemBodyList.isEmpty()) feedItemContainsMoreThanOneWord = true;
    //the topic and feedbody become

    //===========================================================
    //check for exact wording
    String caseInsensitiveTopic = topic.toUpperCase();
    List<String> topicList = SplitStringWithSpace(caseInsensitiveTopic);

    if(topicList.size() > 1 && !topicList.isEmpty()) {
        if(feedItemContainsMoreThanOneWord) {
            //feedItem size > 1, topic size > 1 => direct compare
            //ie feedItem: 'very well', topic: 'very good'
            Integer sizeOfTopic = topicList.size();
            for(Integer i=0; i<=feedItemBodyList.size()-sizeOfTopic; i++) {
                Integer isequal = 0;
                for(Integer j=0; j<sizeOfTopic; j++) {
                    if(feedItemBodyList[i+j].equals(topicList[j]))
                        isequal++;
                    if(isequal == sizeOfTopic) {
                        return true;
                    }
                }
            }
        }
        else{
            //feedItem size == 1, topic size > 1 => false
            //ie feedItem: 'good', topic: 'very good'
            feedItemBodyContainsTopic = false;
        }
    }
    else{
        if(feedItemContainsMoreThanOneWord) {
            //feedItem size > 1, topic size == 1 => exact compare for each split
            //ie feedItem: 'Ab Cd Ef Gh', topic: 'g'
            for(String check : feedItemBodyList) {
                if(check.equals(caseInsensitiveTopic)) {
                    return true;
                }
            }
        }
        else{
            //feedItem size == 1, topic size == 1 => false
            //ie feedItem: 'good', topic: 'well'
            if(caseInsensitiveTopic.equals(feedItemBodyList[0])) {
                feedItemBodyContainsTopic = true;
            }
        }
    }
    //===========================================================
    return feedItemBodyContainsTopic;
}

public static String TopicInLightning(String body, List<String> TopicList) {
    body += '<p>';
    for(String newTopic : TopicList)
        body += '#['+ newTopic + '] ';
    body += '</p>';
    return body;
}
}