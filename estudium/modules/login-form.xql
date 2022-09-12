xquery version "3.0";

let $currentUser := sm:id()
        
return





<div xmlns="http://www.w3.org/1999/xhtml" data-template="templates:surround"
    data-template-with="./templates/page.html" data-template-at="content">
    
    
    <!--
    
     <script src="http://thot.philo.ulg.ac.be/apps/thot-studio/resources/scripts/loadthesaurus.js" type="text/javascript"/>
    <script src="http://thot.philo.ulg.ac.be/apps/thot-studio/resources/scripts/thottree.js" type="text/javascript"/>   -->

    <script src="http://thot.philo.ulg.ac.be/apps/thot/resources/scripts/reloadpage.js" type="text/javascript"/>
   <div class="container">
   <div class="row">
            <div class="container-fluid">
         
      
      <h2>User login</h2>
        <form action="/modules/login.xql" method="post">               
            <div class="form-group">
                <label for="user">Username</label>
                <input class="form-control" type="text" id="user" name="user" value=""/>        
            </div>
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" class="form-control"/>  
            </div>
    <div class="form-actions">
            <button type="submit" class="btn btn-default">Login</button>
        </div>
        
                  
                    
        </form>
      
      </div>
</div></div></div>      