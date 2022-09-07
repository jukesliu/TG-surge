#!/usr/bin/env python
# coding: utf-8

# In[1]:


def rio_write(out_path, nparray, ref_raster, grid_spacing):
    # Function to write a numpy array to a Geotiff using rasterio
    # The geotiff will have the same bounds and crs as the reference raster
    # An evenly-spaced grid will be created with the grid spacing entered
    #
    # INPUTS:
    #   out_path: the path with name of the output gtiff file
    #   nparray: the nparray to write to gtiff
    #   ref_raster: the reference raster (we borrow its crs and bounding coordinates)
    #   grid_spacing: the spatial resolution of the output raster
    
    import rasterio as rio
    import numpy as np
    nparray = np.array(nparray) # make sure it's an np array
    
    with rio.open(out_path,'w',
                      driver='GTiff',
                      height=nparray.shape[0], # new shape
                      width=nparray.shape[1], # new shape
                      dtype=nparray.dtype, # data type
                      count=1,
                      crs=ref_raster.crs, # the EPSG from the original DEM
                      transform=rio.Affine(grid_spacing, 0.0, ref_raster.bounds.left, # modified transform
                                           0.0, -grid_spacing, ref_raster.bounds.top)) as dst:
            dst.write(nparray, 1)


# In[2]:


def download_orbits(SAFEzipfilepath, config_path, out_dir):
    # DOWNLOADS PRECISE ORBIT FILES FROM ASF
    # Requires installation of wget
    # INPUTS:
    #  SAFEzipfilepath: path to the SAFE file 
    #  configpath: 
    #  our_dir: path to the orbit directory where orbit files will be saved
    
    orb_type = 'aux_poeorb'
    zipname = SAFEzipfilepath.split('/')[-1] 
    time = zipname.split('_')[5]
    S1 = zipname.split('_')[0][-3:]
    scene_center_time = datetime.datetime.strptime(time,"%Y%m%dT%H%M%S")
    validity_start_time = scene_center_time-datetime.timedelta(days=1)
    validity_end_time =  scene_center_time+datetime.timedelta(days=1)
    
    # ASF URL
    url = "https://s1qc.asf.alaska.edu/%s/?validity_start=%s&validity_start=%s&validity_start=%s&sentinel1__mission=%s" % (orb_type, validity_start_time.strftime("%Y"),validity_start_time.strftime("%Y-%m"), validity_start_time.strftime("%Y-%m-%d"), S1)   
    content = ( urllib.request.urlopen(url).read()) # read results
    ii = re.findall('''href=["'](.[^"']+)["']''', content.decode('utf-8'))
    
    for i in ii :
        if '.EOF' in i:
            if (validity_start_time.strftime("%Y%m%d") in i) and (validity_end_time.strftime("%Y%m%d") in i) and (S1 in i):
                
                # if it doesn't already exist
                if not os.path.isfile(out_dir+i):
                    wget_cmd = 'export WGETRC="'+config_path+'"; '
                    wget_cmd += 'wget -c -P '+out_dir+' '
                    wget_cmd += "https://s1qc.asf.alaska.edu/aux_poeorb/"+i
    #                 print(wget_cmd)
                    subprocess.run(wget_cmd, shell=True,check=True)  
                    print(i+' downloaded.')
                else:
                    print(i+' already exists in orbit folder.')


# In[3]:


# create .netrc file with Earthdata credentials
def create_netrc(netrc_name):
    from netrc import netrc
    from subprocess import Popen
    from getpass import getpass
    
    homeDir = os.path.expanduser("~")
    if os.path.exists(homeDir+'/'+netrc_name):
        print(netrc_name, ' with Earthdata credentials already exists.')

    urs = 'urs.earthdata.nasa.gov'    # Earthdata URL endpoint for authentication
    prompts = ['Enter NASA Earthdata Login Username: ',
               'Enter NASA Earthdata Login Password: ']
    # Determine if netrc file exists, and if so, if it includes NASA Earthdata Login Credentials
    try:
        netrcDir = os.path.expanduser(f"~/{netrc_name}")
        netrc(netrcDir).authenticators(urs)[0]
    # Below, create a netrc file and prompt user for NASA Earthdata Login Username and Password
    except FileNotFoundError:
        Popen('touch {0}{2} | echo machine {1} >> {0}{2}'.format(homeDir + os.sep, urs, netrc_name), shell=True)
        Popen('echo login {} >> {}{}'.format(getpass(prompt=prompts[0]), homeDir + os.sep, netrc_name), shell=True)
        Popen('echo \'password {} \'>> {}{}'.format(getpass(prompt=prompts[1]), homeDir + os.sep, netrc_name), shell=True)
        # Set restrictive permissions
        Popen('chmod 0600 {0}{1}'.format(homeDir + os.sep, netrc_name), shell=True)


# In[ ]:




