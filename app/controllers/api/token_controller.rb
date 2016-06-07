#``
#The MIT License (MIT)
#
#Copyright (c) 2016, Groupon, Inc.
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.
#
require 'securerandom'

class Api::TokenController < ApplicationController
  respond_to :json
  before_filter :authz

  def index
    render(:json => @current_user.tokens)
  end

  def show
    render(:json => Token.find(params[:id]))
  rescue ActiveRecord::RecordNotFound
    render(:json => {error: "no token with that id found}"}, :status => 404)
  end

  def create
    token = Token.create(:user => @current_user, :name => params[:name], :token => Digest::SHA2.new(256).update(SecureRandom.random_bytes).to_s)

    if token.valid?
      render(:json => token)
    else
      render(:json => {error: "duplicate token name not allowed"}, :status => 409)
    end
  end

  def destroy
    token = Token.find(params[:id])

    if @current_user == token.user and token.destroy
      render(:json => {result: "success"})
    else
      render(:json => {result: "failed"}, :status => 500)
    end
  rescue ActiveRecord::RecordNotFound
    render(:json => {error: "no token with that id found}"}, :status => 404)
  end

end
