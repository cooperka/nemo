��    E      D              l     m     t     �     �     �  
   �     �     �  B  �     %     )  c   F     �  N   �  �     �   �    �     �	  	   �	  z   �	  	   
  �   %
  �   �
     Y  t   v  ;   �  5   '  A   ]  T   �  -   �  I   "     l  I   �  ;   �  +     ,   =  r   j  '   �  @        F     a  J   x     �  G   �     !     '     /     5  �   >          '     .     4     ;     B     H     P     Y  	   `     j     r  
   �     �     �     �     �     �  	   �  H  �     �               ,     9  
   H     S     c  B  t     �     �  c   �     <  N   E  �   �  �   >           	   (  z   2  	   �  �   �  �   j     �  t     ;   }  5   �  A   �  T   1  -   �  I   �     �  I     ;   g  +   �  ,   �  r   �  '   o  @   �     �     �  J   
     U  G   k     �     �     �     �  �   �     �     �     �     �     �     �     �     �     �  	   �     �        
               "      (      /      5   	   >    (… ) **Questions menu** **Responses menu** **SMS Menu** **Users menu** 10. Search 10.1. Operators 10.2. Qualifiers A qualifier is a word you add to an expression to specify where to search. For example, searching **form: observation** within the Responses menu will return all forms with the word “observation” in them. Another example: searching **type: long** text in the Questions menu returns all questions of the long text type. AND Answers to textual questions Available qualifiers depend on the view or menu that you are working within. They are listed below: Function Grouping parenthesis explicitly denotes the argument boundaries. example: (red Keywords are just the words you use in your search. Combining Keywords with Operators give the parameters for a search to occur. Keywords and Operators form Expressions. Matches when any of its two arguments match. example: one \| two returns matches that have one OR two example: “Opening Form” \| “Polling Form” returns matches that are that are Opening Form or Polling Form. Matches when the first argument matches, but the second one does not. example: form != Closing returns the matches of forms that are NOT the Closing form example: ballot -box matches any response with an answer containing the word ballot but NOT the word box. NOT (!= or -) OR ( \| ) Operators in ELMO are: **AND, OR, NOT**\ ( ! or -), **grouping** operator (parentheses), and **phrase** operator (“”). Qualifier Quotes match when argument Keywords match an exact phrase. example: “The red fox jumped over the fence“ example: “Voter lines went outside the center and down the street“ Searching is a critical aspect of being able to find the information you need. This function is available on many parts of ELMO. Tags applied to the question The date and time the message was sent or received (use quotation marks and 24-hr time, e.g. “2015-01-29 14:00”) The date the message was sent or received (e.g. 2015-01-29) The date the response was submitted (e.g. 1985-03-22) The full name of the sender or receiver (partial matches allowed) The medium via which the response was submitted (‘web’, ‘odk’, or ‘sms’) The message content (partial matches allowed) The message type (incoming, reply, or broadcast) (partial matches allowed The name of the form submitted The name of the user that submitted the response (partial matches allowed The phone number of the sender or receiver (partial matches The question code (partial matches allowed) The question title (partial matches allowed) The question type (text, long-text, integer, decimal, location, select-one, select-multiple, datetime, date, time) The user group that the user belongs to The username of the sender or receiver (partial matches allowed) The user’s email address The user’s full name The user’s phone number (no dashes or other punctuation, e.g. 1112223333 The user’s username Whether the response has been marked ‘reviewed’ (1 = yes or 0 = no) code: content date: datetime default implicit operator; matches when both of its arguments match example (with three keywords and two implicit AND operators between them): voters ballots stations returns matches with voters AND ballots AND stations. description email: form: group: login: name: number: operator phone: reviewed: source: submit-date : submitter: tag: text: title: type: username “…” Project-Id-Version: Elmo 7.0
Report-Msgid-Bugs-To: 
POT-Creation-Date: 2018-01-10 16:48+0100
PO-Revision-Date: YEAR-MO-DA HO:MI+ZONE
Last-Translator: FULL NAME <EMAIL@ADDRESS>
Language-Team: LANGUAGE <LL@li.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Generated-By: Babel 2.5.1
 (… ) **Questions menu** **Responses menu** **SMS Menu** **Users menu** 10. Search 10.1. Operators 10.2. Qualifiers A qualifier is a word you add to an expression to specify where to search. For example, searching **form: observation** within the Responses menu will return all forms with the word “observation” in them. Another example: searching **type: long** text in the Questions menu returns all questions of the long text type. AND Answers to textual questions Available qualifiers depend on the view or menu that you are working within. They are listed below: Function Grouping parenthesis explicitly denotes the argument boundaries. example: (red Keywords are just the words you use in your search. Combining Keywords with Operators give the parameters for a search to occur. Keywords and Operators form Expressions. Matches when any of its two arguments match. example: one \| two returns matches that have one OR two example: “Opening Form” \| “Polling Form” returns matches that are that are Opening Form or Polling Form. Matches when the first argument matches, but the second one does not. example: form != Closing returns the matches of forms that are NOT the Closing form example: ballot -box matches any response with an answer containing the word ballot but NOT the word box. NOT (!= or -) OR ( \| ) Operators in ELMO are: **AND, OR, NOT**\ ( ! or -), **grouping** operator (parentheses), and **phrase** operator (“”). Qualifier Quotes match when argument Keywords match an exact phrase. example: “The red fox jumped over the fence“ example: “Voter lines went outside the center and down the street“ Searching is a critical aspect of being able to find the information you need. This function is available on many parts of ELMO. Tags applied to the question The date and time the message was sent or received (use quotation marks and 24-hr time, e.g. “2015-01-29 14:00”) The date the message was sent or received (e.g. 2015-01-29) The date the response was submitted (e.g. 1985-03-22) The full name of the sender or receiver (partial matches allowed) The medium via which the response was submitted (‘web’, ‘odk’, or ‘sms’) The message content (partial matches allowed) The message type (incoming, reply, or broadcast) (partial matches allowed The name of the form submitted The name of the user that submitted the response (partial matches allowed The phone number of the sender or receiver (partial matches The question code (partial matches allowed) The question title (partial matches allowed) The question type (text, long-text, integer, decimal, location, select-one, select-multiple, datetime, date, time) The user group that the user belongs to The username of the sender or receiver (partial matches allowed) The user’s email address The user’s full name The user’s phone number (no dashes or other punctuation, e.g. 1112223333 The user’s username Whether the response has been marked ‘reviewed’ (1 = yes or 0 = no) code: content date: datetime default implicit operator; matches when both of its arguments match example (with three keywords and two implicit AND operators between them): voters ballots stations returns matches with voters AND ballots AND stations. description email: form: group: login: name: number: operator phone: reviewed: source: submit-date : submitter: tag: text: title: type: username “…” 