require 'sqlite3'
require 'singleton'

class QuestionsDatabase < SQLite3::Database
    include Singleton

    def initialize
        super('questions.db')
        self.type_translation = true
        self.results_as_hash = true
    end

end

class User

    attr_accessor :id, :fname, :lname

    def self.find_by_id(id)
        user = QuestionsDatabase.instance.execute(<<-SQL, id)
        SELECT
            *
        FROM
            users
        WHERE
            id = ?
        SQL
        return nil unless user.length > 0 # person is stored in an array!

        User.new(user.first)
    end

    def self.find_by_name(fname, lname)
        users = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
        SELECT
            *
        FROM
            users
        WHERE
            fname = ? AND lname = ?
        SQL
        return nil unless users.length > 0 # person is stored in an array!

        users.map { |option| User.new(option) }
    end

    def initialize(options)
        @id = options['id']
        @fname = options['fname']
        @lname = options['lname']
    end

    def authored_questions
        Question.find_by_author_id(self.id)
    end

    def authored_replies
        Reply.find_by_user_id(self.id)
    end

    def followed_questions
        QuestionFollow.followed_questions_for_user_id(self.id)
    end

end

class Question

    attr_accessor :id, :title, :user_id, :body

    def self.find_by_id(id)
        question = QuestionsDatabase.instance.execute(<<-SQL, id)
        SELECT
            *
        FROM
            questions
        WHERE
            id = ?
        SQL
        return nil unless question.length > 0

        Question.new(question.first)
    end

    def self.find_by_author_id(author_id)
        question = []
        
        author_questions = QuestionsDatabase.instance.execute(<<-SQL, author_id)
        SELECT
            *
        FROM
            questions
        WHERE
            user_id = ?
        SQL
        return nil unless author_questions.length > 0

        author_questions.each { |option| question << Question.new(option) }
        
        question
    end

    def initialize(options)
        @id = options['id']
        @title = options['title']
        @body = options['body']
        @user_id = options['user_id']
    end

    def author
        User.find_by_id(self.user_id)
    end

    def replies
        Reply.find_by_question_id(self.id)
    end

    def followers
        QuestionFollow.followers_for_question_id(self.id)
    end


end

class QuestionFollow

    attr_accessor :id, :question_id, :user_id

    def self.find_by_id(id)
        question_follow = QuestionsDatabase.instance.execute(<<-SQL, id)
        SELECT
            *
        FROM
            question_follows
        WHERE
            id = ?
        SQL
        return nil unless question_follow.length > 0

        QuestionFollow.new(question_follow.first)
    end

    def self.followers_for_question_id(question_id)
        users = []

        question_followers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
        SELECT
            user_id
        FROM
            question_follows
        WHERE
            question_id = ?;
        SQL
        return nil unless question_followers.length > 0

        question_followers.each { |user| users << User.find_by_id(user["user_id"])}

        users
    end

    def self.followed_questions_for_user_id(user_id)
        questions = []

        follower_questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
        SELECT
            question_id
        FROM
            question_follows
        WHERE
            user_id = ?;
        SQL
        return nil unless follower_questions.length > 0

        follower_questions.each { |question| questions << Question.find_by_id(question["question_id"])}

        questions
    end

    def self.most_followed_questions(n)
        questions = []

        questions_arr = QuestionsDatabase.instance.execute(<<-SQL, n)
        SELECT
            question_id
        FROM
            question_follows
        GROUP BY
            x
        ORDER BY
            gemsglkkn;
        SQL
        return nil unless follower_questions.length > 0

        follower_questions.each { |question| questions << Question.find_by_id(question["question_id"])}

        questions
    end

    def initialize(options)
        @id = options['id']
        @question_id = options['question_id']
        @user_id = options['user_id']
    end

end

class Reply
    
    attr_accessor :id, :question_id, :body, :parent_reply_id, :author_id

    def self.find_by_id(id)
        reply = QuestionsDatabase.instance.execute(<<-SQL, id)
        SELECT
            *
        FROM
            replies
        WHERE
            id = ?
        SQL
        return nil unless reply.length > 0

        Reply.new(reply.first)
    end

    def self.find_by_user_id(user_id)
        replies = []
        
        user_replies = QuestionsDatabase.instance.execute(<<-SQL, user_id)
        SELECT
            *
        FROM
            replies
        WHERE
            author_id = ?
        SQL
        return nil unless user_replies.length > 0

        user_replies.each { |option| replies << Reply.new(option) }
        
        replies
    end

    def self.find_by_question_id(question_id)
        replies = []
        
        question_replies = QuestionsDatabase.instance.execute(<<-SQL, question_id)
        SELECT
            *
        FROM
            replies
        WHERE
            question_id = ?
        SQL
        return nil unless question_replies.length > 0

        question_replies.each { |option| replies << Reply.new(option) }
        
        replies
    end

    def initialize(options)
        @id = options['id']
        @body = options['body']
        @question_id = options['question_id']
        @parent_reply_id = options['parent_reply_id']
        @author_id = options['author_id']
    end

    def author
        User.find_by_id(self.author_id)
    end

    def question
        Question.find_by_id(self.question_id)
    end

    def parent_reply
        Reply.find_by_id(self.parent_reply_id)
    end

    def child_replies
        replies = []
        
        user_replies = QuestionsDatabase.instance.execute(<<-SQL)
        SELECT
            *
        FROM
            replies;
        SQL
        return nil unless user_replies.length > 0

        user_replies.each { |reply| replies << Reply.new(reply) if self.id == reply["parent_reply_id"] }
        
        replies
    end

    # what is oop?
    # 1. oop is obj...
    # 2. cool - what reply has a parent reply is that is my id ie 2
    # 3. you got it - parent reply id is 2
    # 4. so smart

end

class QuestionLike

    attr_accessor :id, :question_id, :user_id
     def self.find_by_id(id)
        question_like = QuestionsDatabase.instance.execute(<<-SQL, id)
        SELECT
            *
        FROM
            question_likes
        WHERE
            id = ?
        SQL
        return nil unless question_like.length > 0

        QuestionLike.new(question_like.first)
    end

    def initialize(options)
        @id = options['id']
        @question_id = options['question_id']
        @user_id = options['user_id']
    end
  
end