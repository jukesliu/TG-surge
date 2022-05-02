import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
    
def mytomd(array):
    # convert speed in m/yr to m/day
    return np.array(array)/365

def vector_magnitude(xarray, yarray):
    # calculate vector magnitude (e.g., speed from velocity)
    x = np.array(xarray); y = np.array(yarray)
    return np.sqrt((y**2) + (x**2))

def euc_distance(x1,y1,x2,y2):
    # calculate euclidian distances
    dist = np.sqrt(((x1-x2)**2)+(y1-y2)**2)
    return dist

# PLOTTING AND DATA ANALYSIS
def unique_date_df(df,d1colname,d2colname):
    # Grab unique date pairs from a data frame containing centerline values
    # from many dates. d1colname and d2colname refer to the DataFrame column
    # names corresponding to the first and second dates in the pair
    df2 = pd.DataFrame(list(OrderedSet(zip(df[d1colname], df[d2colname]))),
                   columns=[d1colname,d2colname])
    df2 = df2.drop_duplicates()
    return df2

def plot_by_sensor(ins3xr, pt_variable, max_dt):
        # Adapted from velocity widget code to plot velocities colored by satellite sensor
        try:
            sat = np.array([x[0] for x in ins3xr["satellite_img1"].values])
        except:
            sat = np.array([str(int(x)) for x in ins3xr["satellite_img1"].values])

        sats = np.unique(sat)
        sat_plotsym_dict = {"1": "r+", "2": "b+", "8": "g+","9": "m+",}
        sat_label_dict = {"1": "Sentinel 1", "2": "Sentinel 2","8": "Landsat 8", "9": "Landsat 9"}
        
        fig, ax = plt.subplots(1,1)
        ax.set_xlabel("Date")
        ax.set_ylabel("Speed (m/yr)")
        ax.set_title("ITS_LIVE Ice Flow Speed m/yr")
        dt = ins3xr["date_dt"].values
        dt = dt.astype(float) * 1.15741e-14

        for satellite in sats[::-1]:
            if any(sat == satellite):
                ax.plot(
                    ins3xr["mid_date"][(sat == satellite) & (dt < max_dt)],
                    pt_variable[(sat == satellite) & (dt < max_dt)],
                    sat_plotsym_dict[satellite],
                    label=sat_label_dict[satellite],
                )
        plt.legend()
        plt.grid()
        plt.show()
                
def grab_v_by_sensor(ins3xr, pt_variable, max_dt, sensor_list):
    dfs = [] # list to hold dataframes

    for sensor in sensor_list:
        # grab indexes that match sensor and time separation
        idx = np.where((ins3xr.satellite_img1 == sensor) & 
                      ((ins3xr.date_dt).astype(float)*1.15741e-14 < max_dt)) # max dt
        if len(idx[0]) > 0:
            # grab the variables
            mid_dates = ins3xr.mid_date[idx].values
            v = pt_variable[idx].values
            d1 = ins3xr.acquisition_date_img1[idx].values
            d2 = ins3xr.acquisition_date_img2[idx].values
            sensors = ins3xr.satellite_img1[idx].values

            # add into dataframe
            df = pd.DataFrame(list(zip(mid_dates,d1,d2,sensors,v)),columns=['mid_date','ds1','ds2','sat','v'])
            dfs.append(df)

    total_df = pd.concat(dfs) # combined data
    
    return np.array(total_df.mid_date), np.array(total_df.v), np.array(total_df.ds1), np.array(total_df.ds2), np.array(total_df.sat)
