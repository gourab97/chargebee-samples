require 'chargebee'
require 'json'

class TrialSignupController < ApplicationController
 
 def create
    begin
      result = create_subscription(params)
      
      # Forwarding to success page after trial subscription created successfully in ChargeBee.
      render json: {
        :forward => "thankyou.html?name=#{URI.escape(result.customer.first_name)}&planId=#{URI.escape(result.subscription.plan_id)}"
      }
      
    rescue ChargeBee::APIError => e
      # ChargeBee exception is captured through APIException and 
      # the error messsage (as JSON) is sent to the client.
      render json: e.json_obj, status: e.json_obj[:http_status_code]
    rescue Exception => e
      # Other errors are captured here and error messsage (as JSON) 
      # sent to the client.
      # Note: Here the subscription might have been created in ChargeBee 
      #       before the exception has occured.
      render status: 500, json: {
        :error_msg => "Error while creating your subscription"
      }
    end
 end


 def create_subscription(_params)
    
    # Constructing the request parameters and sending request to ChargeBee server 
    # to create a trial subscription. 
    # For demo purpose plan with id 'basic' with trial period 15 days at 
    # ChargeBee app is hard coded here.
    #
    # Note : Here customer object received from client side is sent directly 
    #        to ChargeBee.It is possible as the html form's input names are 
    #        in the format customer[<attribute name>] eg: customer[first_name] 
    #        and hence the $_POST["customer"] returns an associative array of the attributes.               
    result = ChargeBee::Subscription.create({ :plan_id => "basic",
                                              :customer => _params['customer'] })
    return result
   
 end

end
