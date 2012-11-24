require 'spec_helper'

describe SessionsController do
  describe 'GET "new"' do
    before(:each) do
      get :new
    end

    it 'should be successful' do
      response.should be_success
    end

    it 'should render the new page' do
      response.should render_template('new')
    end
  end

  describe 'GET "index"' do
    context 'when logged out' do
      it 'should redirect to the login page' do
        get :index
        response.should redirect_to(new_session_path)
      end
    end
  end

  describe 'POST "create"' do
    context 'without a valid login ticket' do
      before(:each) do
        post :create
      end

      it 'should render the new page' do
        response.should render_template('new')
      end

      it 'should have a flash message' do
        flash[:error].should =~ /no valid login ticket/i
      end

      it 'should respond with a 403' do
        response.response_code.should == 403
      end
    end

    context 'with a valid login ticket' do
      context 'with invalid login data' do
        before(:each) do
          ticket = LoginTicket.create! ticket: 'LT-54321'
          post :create, {
            lt: ticket.ticket,
            username: 'bla',
            password: 'test123'
          }
        end

        it 'should render the new page' do
          response.should render_template('new')
        end

        it 'should have a flash message' do
          flash[:error].should =~ /incorrect/i
        end

        it 'should respond with a 403' do
          response.response_code.should == 403
        end
      end

      context 'with valid login data' do
        before(:each) do
          ticket = LoginTicket.create! ticket: 'LT-43821'
          post :create, {
            lt: ticket.ticket,
            username: 'testuser',
            password: 'foobar123'
          }
        end

        it 'should redirect to the index page' do
          response.should redirect_to(sessions_path)
        end
      end
    end
  end
end
